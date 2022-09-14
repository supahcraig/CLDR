# credit where credit is due:
# http://funnifi.blogspot.com/2016/03/executescript-json-to-json-revisited_14.html

import json
import java.io
from datetime import datetime
from org.apache.commons.io import IOUtils
from java.nio.charset import StandardCharsets
from org.apache.nifi.processor.io import StreamCallback

class PyStreamCallback(StreamCallback):
	def __init__(self):
		pass

	def process(self, inputStream, outputStream):
		text = IOUtils.toString(inputStream, StandardCharsets.UTF_8)
		flowFileJson = json.loads(text)
		today_string = datetime.today().strftime('%Y-%m-%d')
		flowFileJson['current_date'] = today_string

		outputStream.write(bytearray(json.dumps(flowFileJson, indent=4).encode('utf-8')))


flowFile = session.get()
if (flowFile != None):
	flowFile = session.write(flowFile,PyStreamCallback())
	session.transfer(flowFile, REL_SUCCESS)
	
