import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

import boto3


AWS_REGION = os.environ.get("AWS_REGION", "ap-south-1")
BEDROCK_MODEL_ID = os.environ.get(
    "BEDROCK_MODEL_ID",
    "global.amazon.nova-2-lite-v1:0"
)

bedrock = boto3.client(
    "bedrock-runtime",
    region_name=AWS_REGION
)


class Handler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path == "/health":
            body = b"OK\n"
            content_type = "text/plain"

        elif self.path == "/bedrock":
            try:
                request_body = {
                    "messages": [
                        {
                            "role": "user",
                            "content": [
                                {
                                    "text": "Reply with exactly: UAT Bedrock integration successful"
                                }
                            ]
                        }
                    ],
                    "inferenceConfig": {
                        "maxTokens": 50,
                        "temperature": 0
                    }
                }

                response = bedrock.invoke_model(
                    modelId=BEDROCK_MODEL_ID,
                    body=json.dumps(request_body),
                    contentType="application/json",
                    accept="application/json"
                )

                response_body = json.loads(
                    response["body"].read()
                )

                text = response_body["output"]["message"]["content"][0]["text"]

                body = (text + "\n").encode()
                content_type = "text/plain"

            except Exception as e:
                print(f"Bedrock error: {e}")

                body = (
                    "Bedrock invocation failed: "
                    + str(e)
                    + "\n"
                ).encode()

                content_type = "text/plain"

        else:
            body = b"Hello from PostStack Migration ECS - CI/CD v2!\n"
            content_type = "text/plain"

        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        print(format % args)


server = HTTPServer(("0.0.0.0", 8080), Handler)

print("Application listening on port 8080")
print(f"Bedrock region: {AWS_REGION}")
print(f"Bedrock model: {BEDROCK_MODEL_ID}")

server.serve_forever()
