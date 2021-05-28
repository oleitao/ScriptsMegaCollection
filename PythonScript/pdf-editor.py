# PDF editor
import PyPDF2
file = input(
    "What is the name of your pdf file you want to extract a page from: ")
pdfFileObj = open(file + '.pdf', 'rb')
pdfReader = PyPDF2.PdfFileReader(pdfFileObj)
pgnumber = input("Which page would you like to extract?: ")
pageObj = pdfReader.getPage(int(pgnumber) - 1)
pdfWriter = PyPDF2.PdfFileWriter()
pdfWriter.addPage(pageObj)
outputfile = input("Name new pdf file: ")
pdfOutputFile = open(outputfile + '.pdf', 'wb')
pdfWriter.write(pdfOutputFile)
pdfOutputFile.close()
