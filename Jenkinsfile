node {
	stage('Clone repository') {
		checkout scm
	}

	stage('Validate') {
		sh 'chmod +x validate.sh && ./validate.sh';
	}
}