node {
	try {
		stage('Clone repository') {
			checkout scm
		}

		stage('Validate') {
			sh """wget https://github.com/instrumenta/kubeval/releases/download/0.9.2/kubeval-linux-amd64.tar.gz && \
				tar xf kubeval-linux-amd64.tar.gz && \
				./validate.sh
			""";
		}

		sendNotification("SUCCESS", "Successfully validated kubernetes manifest files.");
	} catch (e) {
		sendNotification("FAILED", "Validation of kubernetes manifest files failed!");
		throw e
	}
}

def sendNotification(String status, String message) {
	def webhook = "https://outlook.office.com/webhook/fd963f0b-eb27-4b22-8692-218ace3f4fba@4a7853bd-0ffb-40ff-904c-b20996f4be78/JenkinsCI/bcdd04c05ce4488a87aaeb92d7f570fb/28d07d2b-d458-4324-82df-e8ee143b3267";

	// Send microsoft teams notification
	office365ConnectorSend (message: message, status: status, webhookUrl: webhook);
}