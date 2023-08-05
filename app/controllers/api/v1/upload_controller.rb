# app/controllers/api/v1/upload_controller.rb
class Api::V1::UploadController < ApplicationController
    def create
      jpg_file = params[:jpgFile]
      pdf_file = params[:pdfFile]

    #   # Convertir le fichier JPG en PDF si nécessaire
    # if jpg_file.content_type == "image/jpeg"
    #     jpg_image = MiniMagick::Image.read(jpg_file)
    #     jpg_image.format "pdf"
    #     jpg_file = Tempfile.new(["converted", ".pdf"], binmode: true)
    #     jpg_image.write jpg_file.path
    # end
  
    # combined_pdf = CombinePDF.new
    # combined_pdf << CombinePDF.load(jpg_file.path) if jpg_file.content_type == "application/pdf"
    # combined_pdf << CombinePDF.load(pdf_file.path)

    # # Sauvegarder le fichier final
    # final_pdf_path = Rails.root.join("tmp", "final.pdf")
    # combined_pdf.save final_pdf_path

    # final_pdf = File.read(final_pdf_path)
  
    render json: { message: "Fichiers téléchargés avec succès !" }, status: :ok
rescue => e
  render json: { error: "Une erreur est survenue lors du traitement des fichiers." }, status: :unprocessable_entity
end
end