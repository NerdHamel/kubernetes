const { statSync, mkdirSync, readFileSync, writeFileSync } = require("fs");
const { randomBytes } = require("crypto");
const { join } = require("path");
const { safeLoad, safeDump } = require("js-yaml");

function createRandomString(length) {
	return randomBytes(length).toString('hex');
}

function toBase64(str) {
	return Buffer.from(str).toString('base64');
}

function createCompactSecret() {
	return createRandomString(64);
}

function createLongSecret() {
	return createRandomString(128);
}

function createDummySecret() {
	return 'aaa';
}

function generateSecretsFolder() {
	/** Check whether 'core/secrets' already exists */
	const secretsExist = checkSecretsFolder();

	/** Abort if we already have a 'core/secrets' folder */
	if (secretsExist) {
		console.log("It seems that you already have a 'core/secrets' folder. Exiting now.");
		process.exit(0);
	}

	try {
		/** Createe 'core/secrets' */
		mkdirSync(join('core', 'secrets'));
	} catch (err) {
		console.log("Unable to create folder 'secrets'. Exiting now.");
		process.exit(0);
	}
}

function checkSecretsFolder() {
	/** Check whether 'core/secrets' is there */
	let secretExists = true;

	try {
		statSync(join('core', 'secrets'));
	} catch (err) {
		secretsExist = false;
	}

	return secretExists;
}

function readAndParseYaml(path) {
	try {
		const contents = readFileSync(path, 'utf8');

		return safeLoad(contents);
	} catch (err) {
		console.log(`Failed to load and parse yaml at: ${path}. Exiting now.`);
		process.exit(0);
	}
}

function fillSecret(secret) {
	const { data, metadata } = secret;
	const { name } = metadata;
	const serviceName = name.replace('cognigy-', '');

	if (name === "cognigy-rabbitmq") {
		const rabbitPassword = createCompactSecret();
		const connectionString = `amqp://cognigy:${rabbitPassword}@rabbitmq:5672`;
		const connectionStringApi = `http://cognigy:${rabbitPassword}@rabbitmq:15672/api`;

		return {
			...secret,
			data: {
				...data,
				'connection-string': toBase64(connectionString),
				'rabbitmq-password': toBase64(rabbitPassword),
				'connection-string-api': toBase64(connectionStringApi)
			}
		};
	}

	if (data['connection-string'] !== undefined) {
		const dbPassword = createCompactSecret();
		const connectionString = `mongodb://${serviceName}:${dbPassword}@mongo-server:27017/${serviceName}`;

		return {
			...secret,
			data: {
				...data,
				'connection-string': toBase64(connectionString)
			}
		};
	}

	if (data['mongo-initdb-root-password'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'mongo-initdb-root-password': toBase64(createLongSecret())
			}
		};
	}

	if (data['security-smtp-password'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'security-smtp-password': toBase64(createDummySecret())
			}
		};
	}

	if (data['tls.crt'] !== undefined && data['tls.key'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'tls.crt': toBase64(createDummySecret()),
				'tls.key': toBase64(createDummySecret())
			}
		};
	}

	if (data['redis-persistent-password.conf'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'redis-persistent-password.conf': toBase64(`requirepass ${createCompactSecret()}`)
			}
		};
	}

	if (data['amazon-client-id'] !== undefined && data['amazon-client-secret'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'amazon-client-id': toBase64(createDummySecret()),
				'amazon-client-secret': toBase64(createDummySecret())
			}
		};
	}

	if (data['fb-verify-token'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'fb-verify-token': toBase64(createCompactSecret())
			}
		};
	}

	if (data['secret'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'secret': toBase64(createLongSecret())
			}
		};
	}

	if (data['odata-super-api-key'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'odata-super-api-key': toBase64(createCompactSecret())
			}
		}
	}

	return secret;
}

function writeSecret(secret, filename) {
	let yaml = "";

	try {
		yaml = safeDump(secret);
	} catch (err) {
		console.log(`Failed during YAML rendering. Error was: ${err}. Exiting now.`);
		process.exit(1);
	}

	writeFileSync(join('core', 'secrets', filename), yaml);
}

module.exports = {
	generateSecretsFolder,
	checkSecretsFolder,
	readAndParseYaml,
	readFileSync,
	fillSecret,
	writeSecret
}