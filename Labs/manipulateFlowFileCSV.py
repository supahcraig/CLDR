from datetime import datetime
from org.apache.commons.io import IOUtils
from java.nio.charset import StandardCharsets
from org.apache.nifi.processor.io import StreamCallback

class PyStreamCallback(StreamCallback):
	def __init__(self):
		pass

	def process(self, inputStream, outputStream):
		text = IOUtils.toString(inputStream, StandardCharsets.UTF_8)
		today_string = datetime.today().strftime('%Y-%m-%d')
		text = text + ', ' + today_string

		outputStream.write(bytearray(text.encode('utf-8')))


flowFile = session.get()
if (flowFile != None):
	flowFile = session.write(flowFile,PyStreamCallback())
	session.transfer(flowFile, REL_SUCCESS)
	
