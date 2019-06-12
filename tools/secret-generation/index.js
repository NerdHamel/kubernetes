const { readdirSync, statSync, mkdirSync, readFileSync, writeFileSync } = require("fs");
const { randomBytes } = require("crypto");
const { join } = require("path");
const { safeLoad, safeDump } = require("js-yaml");

function createRandomString(length) {
	return randomBytes(length).toString('base64');
}

const dummySecret = 'aaa';
const createCompactSecret = () => createRandomString(64);
const createLongSecret = () => createRandomString(128);

function generateSecretsFolder() {
	/** Check whether 'core/secrets' already exists */
	let secretsExist = true;

	try {
		statSync(join('core', 'secrets'));
	} catch (err) {
		secretsExist = false;
	}

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
				'connection-string': connectionString,
				'rabbitmq-password': rabbitPassword,
				'connection-string-api': connectionStringApi
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
				'connection-string': connectionString
			}
		};
	}

	if (data['mongo-initdb-root-password'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'mongo-initdb-root-password': createLongSecret()
			}
		};
	}

	if (data['security-smtp-password'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'security-smtp-password': dummySecret
			}
		};
	}

	if (data['tls.crt'] !== undefined && data['tls.key'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'tls.crt': dummySecret,
				'tls.key': dummySecret
			}
		};
	}

	if (data['redis-persistent-password.conf'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'redis-persistent-password.conf': `requirepass ${createCompactSecret()}`
			}
		};
	}

	if (data['amazon-client-id'] !== undefined && data['amazon-client-secret'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'amazon-client-id': dummySecret,
				'amazon-client-secret': dummySecret
			}
		};
	}

	if (data['fb-verify-token'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'fb-verify-token': createCompactSecret()
			}
		};
	}

	if (data['secret'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'secret': createLongSecret()
			}
		};
	}

	if (data['odata-super-api-key'] !== undefined) {
		return {
			...secret,
			data: {
				...data,
				'odata-super-api-key': createCompactSecret()
			}
		}
	}

	return secret;
}

function writeFile(secret, filename) {
	let yaml = "";
	
	try {
		yaml = safeDump(secret);
	} catch (err) {
		console.log(`Failed during YAML rendering. Error was: ${err}. Exiting now.`);
		process.exit(1);
	}

	writeFileSync(join('core', 'secrets', filename), yaml);
}

(async () => {
	try {
		/** Generate the 'core/secrets' folder if necessary */
		generateSecretsFolder();

		/** Read dir contents fo 'core/secrets.dist' */
		const files = readdirSync(join('core', 'secrets.dist'));

		/** Read and parse all yaml files (k8s secrets) */
		for (const file of files) {
			const parsedSecret = readAndParseYaml(join('core', 'secrets.dist', file));
			const finalSecret = fillSecret(parsedSecret);
			writeFile(finalSecret, file);
		}
	} catch (err) {
		console.log(`An error occured. Exiting now. Error was: ${err}`);
		process.exit(1);
	}

	process.exit(0);
})();