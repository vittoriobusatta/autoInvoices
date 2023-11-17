import React, { useState } from "react";
import axios from "axios";
import styled from "styled-components";

const domain = process.env.REACT_APP_BACK_DOMAIN;

function FileUploader() {
  const [jpgFile, setJpgFile] = useState(null);
  const [pdfFile, setPdfFile] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [fileName, setFileName] = useState(null);

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
    setLoading(true);
    const formData = new FormData();
    formData.append("jpgFile", jpgFile);
    formData.append("pdfFile", pdfFile);
    try {
      await axios
        .post(`${domain}/api/v1/upload`, formData, {
          method: "POST",
          headers: {
            "Content-Type": "multipart/form-data",
          },
          responseType: "blob",
        })
        .then((res) => {
          const url = window.URL.createObjectURL(new Blob([res.data]));
          const link = document.createElement("a");
          link.href = url;
          link.setAttribute("download", `facture_${fileName}.pdf`);
          document.body.appendChild(link);
          link.click();
          link.parentNode.removeChild(link);
          window.URL.revokeObjectURL(url);
        })
        .finally(() => {
          setJpgFile(null);
          setPdfFile(null);
          setLoading(false);
        })
        .catch((err) => {
          console.log(err.response.data.error);
          setError(err.response.data.error);
        });
    } catch (err) {
      console.error(err);
    }
  };
  return (
    <Container>
      <Title>Fusionner les factures et bons de commande</Title>
      <FileInputContainer>
        <FileInputLabel>Numéro de facture</FileInputLabel>
        <FileInput
          type="text"
          onChange={(e) => setFileName(e.target.value)}
          value={fileName}
        />
      </FileInputContainer>
      <FileInputContainer>
        <FileInputLabel>Met ici ta facture (jpg)</FileInputLabel>
        <FileInput
          type="file"
          accept=".jpg,.jpeg"
          onChange={handleJpgFileChange}
        />
      </FileInputContainer>
      <FileInputContainer>
        <FileInputLabel>Met ici le bon de commande (pdf)</FileInputLabel>
        <FileInput type="file" accept=".pdf" onChange={handlePdfFileChange} />
      </FileInputContainer>
      <SubmitButton onClick={handleSubmit} disabled={loading}>
        {loading ? "Fusion en cours..." : "Fusionner"}
      </SubmitButton>
      {error && <ErrorMessage>{error}</ErrorMessage>}
    </Container>
  );
}

export default FileUploader;

const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background-color: #f3f4f6;
  min-height: 100vh;
`;

const Title = styled.h1`
  color: #333;
  margin-bottom: 20px;
`;

const FileInputContainer = styled.div`
  margin-bottom: 15px;
`;

const FileInputLabel = styled.h2`
  margin-bottom: 5px;
  color: #555;
`;

const FileInput = styled.input`
  padding: 10px;
  border-radius: 5px;
  border: 1px solid #ddd;
  &:focus {
    outline: none;
    border-color: #007bff;
  }
`;

const SubmitButton = styled.button`
  padding: 10px 15px;
  margin-top: 22px;
  border: none;
  border-radius: 5px;
  background-color: #007bff;
  color: white;
  cursor: pointer;
  &:hover {
    background-color: #0056b3;
  }
  &:disabled {
    background-color: #ccc;
  }
`;

const ErrorMessage = styled.h3`
  color: red;
`;
