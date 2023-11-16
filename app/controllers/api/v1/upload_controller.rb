require 'mini_magick'
require 'base64'
require 'dotenv/load'
# app/controllers/api/v1/upload_controller.rb
class Api::V1::UploadController < ApplicationController
    def create
      jpg_file = params[:jpgFile]
      pdf_file = params[:pdfFile]

      cloudconvert = CloudConvert::Client.new(api_key: ENV['CLOUDCONVERT_API_KEY'], sandbox: false)

      jpg_file_contents = Base64.strict_encode64(params[:jpgFile].read)
      pdf_file_contents = Base64.strict_encode64(params[:pdfFile].read)

      job = cloudconvert.jobs.create({
        "tasks": [
            {
                "name": "import-jpg",
                "operation": "import/base64",
                "file": jpg_file_contents,
                "filename": "facture.jpg"
            },
            {
                "name": "import-pdf",
                "operation": "import/base64",
                "file": pdf_file_contents,
                "filename": "facture.pdf"
            },
                      {
              "name": "convert",
              "operation": "convert",
              "input_format": "jpg",
              "output_format": "pdf",
              "engine": "imagemagick",
              "input": [
                  "import-jpg"
              ],
              "fit": "max",
              "strip": false,
              "auto_orient": true
          },
          {

              "name": "merge",
              "operation": "merge",
              "input_format": "pdf",
              "output_format": "pdf",
              "engine": "qpdf",
              "input": [
                  "import-pdf",
                  "convert"
              ],
              "merge_direction": "vertical",
              "merge_mode": "append"
          },
          {
              "name": "export",
              "operation": "export/url",
              "input": [
                  "merge"
              ],
              "inline": false,
              "archive_multiple_files": false,
              "archive_type": "zip"
          }
        ]
      })

      job = cloudconvert.jobs.wait(job.id)

      exported_url_task_id = nil
      job.tasks.each do |task|
        if task.operation == 'export/url'
          exported_url_task_id = task.id
          break 
        end
      end
      
      unless exported_url_task_id.nil?
        exported_url_task = cloudconvert.tasks.wait(exported_url_task_id)
        file = exported_url_task.result.files.first
    
        file_path = Rails.root.join('tmp', 'factures', file.filename)
    
        export = cloudconvert.download(file.url, destination: file_path)
    
        send_file(file_path, filename: file.filename, type: 'application/pdf', disposition: 'attachment')

        return
      end

        render json: { message: "Une erreur est survenue lors du traitement des fichiers."}, status: :unprocessable_entity


    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      render json: { message: "Une erreur est survenue lors du traitement des fichiers.", error: e.message}, status: :unprocessable_entity
    end
  end
  