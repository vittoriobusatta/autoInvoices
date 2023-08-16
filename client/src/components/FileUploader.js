import React, { useState } from "react";
import axios from "axios";

function FileUploader() {
  const [jpgFile, setJpgFile] = useState(null);
  const [pdfFile, setPdfFile] = useState(null);
  const [downloadLink, setDownloadLink] = useState(null);
  const [error, setError] = useState(null);

  const handleJpgFileChange = (e) => {
    const file = e.target.files[0];
    setJpgFile(file);
  };

  const handlePdfFileChange = (e) => {
    const file = e.target.files[0];
    setPdfFile(file);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append("jpgFile", jpgFile);
    formData.append("pdfFile", pdfFile);

    console.log(formData.get("jpgFile"));
    console.log(formData.get("pdfFile"));

    try {
      await axios.post(
        "http://localhost:3000/api/v1/upload",
        formData,
        {
          method: "POST",
          headers: {
            "Content-Type": "multipart/form-data",
          },
        }
      ).then((res) => {
        console.log(res);
        const blob = new Blob([res.data], { type: "application/pdf" });
        const link = window.URL.createObjectURL(blob);
        setDownloadLink(link);
      }).catch((err) => {
        console.log(err.response.data.error);
        setError(err.response.data.error);
      });
    } catch (err) {
      console.error(err);
    }
  };
  return (
    <div>
      <h1>Uploader des fichiers</h1>
      <div>
        <div>
          <h2>jpg</h2>
          <input
            type="file"
            accept=".jpg,.jpeg"
            onChange={handleJpgFileChange}
          />
        </div>
        <div>
          <h2>pdf</h2>
          <input type="file" accept=".pdf" onChange={handlePdfFileChange} />
        </div>
      </div>
      <button onClick={handleSubmit}>Convertir & Fusionner</button>
      {downloadLink && (
        <div>
          <h3>Bien enregistré !</h3>
        </div>
      )}
      {error && (
        <div>
          <h3>{error}</h3>
          </div>
      )}
    </div>
  );
}

export default FileUploader;
