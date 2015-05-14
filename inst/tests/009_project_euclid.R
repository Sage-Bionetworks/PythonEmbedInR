#' # Project Euclid
#' Use the Project Euclid data to test the data transport.

require(PythonInR)
invisible(capture.output(pyConnect()))

require('corpus.Project.Euclid')
data("Project_Euclid")

pySet("pe", Project_Euclid)
pe <- pyGet("pe")
pe[1:2,]
