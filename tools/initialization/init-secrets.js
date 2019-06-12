const { readdirSync } = require("fs");
const { join } = require("path");
const { generateSecretsFolder, readAndParseYaml, fillSecret, writeSecret } = require("./utils");

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
			writeSecret(finalSecret, file);
		}
	} catch (err) {
		console.log(`An error occured. Exiting now. Error was: ${err}`);
		process.exit(1);
	}

	process.exit(0);
})();