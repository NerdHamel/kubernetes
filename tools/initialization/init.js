const { readdirSync } = require("fs");
const { join } = require("path");
const { generateSecretsFolder, readAndParseYaml, fillSecret, writeSecret, writeDatabaseInitialization, createSingleDatabaseScriptSnippet } = require("./utils");

(async () => {
	try {
		/** Generate the 'core/secrets' folder if necessary */
		generateSecretsFolder();

		/** Read dir contents for 'core/secrets.dist' */
		const files = readdirSync(join('core', 'secrets.dist'));

		/** Read and parse all yaml files (k8s secrets) */
		let dbCreationScript = "";

		for (const file of files) {
			const parsedSecret = readAndParseYaml(join('core', 'secrets.dist', file));
			const { secret, serviceName, dbPassword } = fillSecret(parsedSecret);
			writeSecret(secret, file);

			dbCreationScript += createSingleDatabaseScriptSnippet(serviceName, dbPassword);
		}

		/** Write the initialization script for MongoDB on disk */
		writeDatabaseInitialization(dbCreationScript);
	} catch (err) {
		console.log(`An error occured. Exiting now. Error was: ${err}`);
		process.exit(1);
	}

	process.exit(0);
})();