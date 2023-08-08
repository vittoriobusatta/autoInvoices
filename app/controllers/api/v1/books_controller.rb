require 'cloudconvert'
require 'dotenv/load'
require 'mini_magick'

class Api::V1::BooksController < ApplicationController
  before_action :set_book, only: %i[ show update destroy ]

  # GET /books
  def index

    jpg_file = params[:jpg_file]
    pdf_file = params[:pdf_file]

    cloudconvert = CloudConvert::Client.new(api_key: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMzI0ZWFkNzdjZGRjMmUwYTkxNWNmYjI4ZTNjOWQzODExMzQ1MGMzNTNlMmY0NjAzMjI4Mjc5MzkzNGQ0ZjlmMzZiMmZkZmM1MTJjZDE2MmIiLCJpYXQiOjE2OTEyNDg3MjkuMjA4MzA0LCJuYmYiOjE2OTEyNDg3MjkuMjA4MzA1LCJleHAiOjQ4NDY5MjIzMjkuMjAwOTQxLCJzdWIiOiI2NDY0ODUwMCIsInNjb3BlcyI6WyJ1c2VyLnJlYWQiLCJ1c2VyLndyaXRlIiwidGFzay5yZWFkIiwidGFzay53cml0ZSIsIndlYmhvb2sud3JpdGUiLCJ3ZWJob29rLnJlYWQiLCJwcmVzZXQucmVhZCIsInByZXNldC53cml0ZSJdfQ.K45AdlOBk-8R_s-hNRpHndOeQbRDyZ7AWz15-HABpOf8DeW5XrxWpGD1Fec7m-tCfi5jZE9WNdzY1-QFqahLEc_PiYfqAk-qtyAFnqeymQeOkuK3pZvHAUm9cuRTemJC-CUi30FRKnkszyiMzSK_xv3_pj9NUHuJ_-VXQpi0QGuXD1gU1zmadAzaR9ad_7Sm8Hdysw7c7ZOojzUsktZYeem3LKMPQPSeTFoozvsY2heUZH69d8P4D6ZDugiFno4y13BxA1wv4AcbtVeIqhFvcJB2LwSP3jNZqKdV9r8ABOPjUmyWQEyH3F-dyn6jNxoBKjWtjofX_EiX-E835dP_p2tXtaXImSmasxDknDC8DoOTVRyiyyfXQ8n3R-9UwVcoaHMU9_qMZiMFPShv9AV6EtKC9lnpaX3TdSmIuukXygqPtMCEV0Ojd6QBT5ueoqLMKzgf6IuXVMMzhQhKHPqDVennQnmkcsEwAvbvPBIjJGelwcgS3m59dTesSy_xiIRT_yVg-T8qAE09BUm6L07QA9STbXet4Hd31YG2OdQp1cneFGatRiYJbMTk0WMJFdLiF23LIgcgWkZqvVfS2d0Ea3LbeYl3ArbDHKRNNQivXXGe3emquJbwpdroO7tyG45sqiN6NCuZoSYO4g4Etfr4AQ3l7mN51IRZXS9GdPVRjlw', sandbox: false)

    job = cloudconvert.jobs.create({
      "tasks": [
          {
              "name": "import-jpg",
              "operation": "import/upload",
              "file": jpg_file,
              "filename": "image.jpg"
          },
          {
              "name": "import-pdf",
              "operation": "import/upload",
              "file": pdf_file,
              "filename": "image.pdf"
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
              "output_format": "pdf",
              "engine": "qpdf",
              "input": [
                  "import-pdf",
                  "convert"
              ],
              "engine_version": "11.2.0"
          },
          {
              "name": "export-1",
              "operation": "export/url",
              "input": [
                  "merge"
              ],
              "inline": false,
              "archive_multiple_files": false
          }
      ]
  })

    job = cloudconvert.jobs.wait(job.id)

    export_task = job.tasks.where(operation: "export/url").where(status: "finished").first

    file = task.result.files.first

    cloudconvert.download(file.url, "output.pdf")

    render json: { message: "ok" }, status: :ok

  end
  

  # GET /books/1
  def show
    render json: @book
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created, location: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:titke, :body)
    end
end
