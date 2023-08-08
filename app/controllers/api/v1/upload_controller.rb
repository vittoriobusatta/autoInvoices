require 'mini_magick'
require 'base64'
# app/controllers/api/v1/upload_controller.rb
class Api::V1::UploadController < ApplicationController
    def create
      jpg_file = params[:jpgFile]
      pdf_file = params[:pdfFile]

      cloudconvert = CloudConvert::Client.new(api_key: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMzI0ZWFkNzdjZGRjMmUwYTkxNWNmYjI4ZTNjOWQzODExMzQ1MGMzNTNlMmY0NjAzMjI4Mjc5MzkzNGQ0ZjlmMzZiMmZkZmM1MTJjZDE2MmIiLCJpYXQiOjE2OTEyNDg3MjkuMjA4MzA0LCJuYmYiOjE2OTEyNDg3MjkuMjA4MzA1LCJleHAiOjQ4NDY5MjIzMjkuMjAwOTQxLCJzdWIiOiI2NDY0ODUwMCIsInNjb3BlcyI6WyJ1c2VyLnJlYWQiLCJ1c2VyLndyaXRlIiwidGFzay5yZWFkIiwidGFzay53cml0ZSIsIndlYmhvb2sud3JpdGUiLCJ3ZWJob29rLnJlYWQiLCJwcmVzZXQucmVhZCIsInByZXNldC53cml0ZSJdfQ.K45AdlOBk-8R_s-hNRpHndOeQbRDyZ7AWz15-HABpOf8DeW5XrxWpGD1Fec7m-tCfi5jZE9WNdzY1-QFqahLEc_PiYfqAk-qtyAFnqeymQeOkuK3pZvHAUm9cuRTemJC-CUi30FRKnkszyiMzSK_xv3_pj9NUHuJ_-VXQpi0QGuXD1gU1zmadAzaR9ad_7Sm8Hdysw7c7ZOojzUsktZYeem3LKMPQPSeTFoozvsY2heUZH69d8P4D6ZDugiFno4y13BxA1wv4AcbtVeIqhFvcJB2LwSP3jNZqKdV9r8ABOPjUmyWQEyH3F-dyn6jNxoBKjWtjofX_EiX-E835dP_p2tXtaXImSmasxDknDC8DoOTVRyiyyfXQ8n3R-9UwVcoaHMU9_qMZiMFPShv9AV6EtKC9lnpaX3TdSmIuukXygqPtMCEV0Ojd6QBT5ueoqLMKzgf6IuXVMMzhQhKHPqDVennQnmkcsEwAvbvPBIjJGelwcgS3m59dTesSy_xiIRT_yVg-T8qAE09BUm6L07QA9STbXet4Hd31YG2OdQp1cneFGatRiYJbMTk0WMJFdLiF23LIgcgWkZqvVfS2d0Ea3LbeYl3ArbDHKRNNQivXXGe3emquJbwpdroO7tyG45sqiN6NCuZoSYO4g4Etfr4AQ3l7mN51IRZXS9GdPVRjlw', sandbox: false)

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

      puts job


    render json: { message: "Fichiers traités avec succès."}, status: :ok

    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      render json: { error: "Une erreur est survenue lors du traitement des fichiers." }, status: :unprocessable_entity
    end
  end
  