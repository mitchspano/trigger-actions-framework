import lwcEslintPluginLwc from "@lwc/eslint-plugin-lwc";
import babelParser from "@babel/eslint-parser";

export default [
	{ ignores: ["**/*.html", "**/*.css", "**/*js-meta.xml", "**/*.json"] },
	{
		plugins: {
			"@lwc/lwc": lwcEslintPluginLwc
		},

		languageOptions: {
			parser: babelParser,
			ecmaVersion: 13,
			sourceType: "script",

			parserOptions: {
				requireConfigFile: false,

				babelOptions: {
					parserOpts: {
						sourceType: "module",
						plugins: [
							"classProperties",
							[
								"decorators",
								{
									decoratorsBeforeExport: false
								}
							]
						]
					}
				}
			}
		},

		rules: {
			"@lwc/lwc/consistent-component-name": "error",
			"@lwc/lwc/no-api-reassignments": "off",
			"@lwc/lwc/no-async-operation": "error",
			"@lwc/lwc/no-attributes-during-construction": "error",
			"@lwc/lwc/no-deprecated": "error",
			"@lwc/lwc/no-document-query": "error",
			"@lwc/lwc/no-dupe-class-members": "error",
			"@lwc/lwc/no-inner-html": "error",
			"@lwc/lwc/no-leading-uppercase-api-name": "error",
			"@lwc/lwc/prefer-custom-event": "error",

			"@lwc/lwc/valid-api": [
				"error",
				{
					disallowUnderscoreUppercaseMix: true
				}
			],

			"array-callback-return": "error",
			"consistent-return": "error",
			"default-case": "error",
			"dot-notation": "error",
			eqeqeq: ["error", "smart"],
			"guard-for-in": "error",
			"handle-callback-err": "error",
			"no-alert": "error",
			"no-await-in-loop": "error",
			"no-caller": "error",
			"no-confusing-arrow": "error",
			"no-console": "warn",
			"no-else-return": "error",
			"no-eval": "error",
			"no-extend-native": "error",
			"no-extra-bind": "error",
			"no-implicit-coercion": "error",

			"no-empty-function": [
				"error",
				{
					allow: ["arrowFunctions", "functions", "methods"]
				}
			],

			"no-floating-decimal": "error",
			"no-implied-eval": "error",
			"no-iterator": "error",
			"no-label-var": "error",
			"no-labels": "error",
			"no-loop-func": "error",
			"no-multi-str": "error",
			"no-new-func": "error",
			"no-new-object": "error",
			"no-new-wrappers": "error",
			"no-new": "error",
			"no-octal-escape": "error",
			"no-proto": "error",
			"no-return-assign": "error",
			"no-return-await": "error",
			"no-script-url": "error",
			"no-self-compare": "error",
			"no-sequences": "error",
			"no-shadow-restricted-names": "error",
			"no-shadow": "error",
			"no-throw-literal": "error",
			"no-undef-init": "error",
			"no-unused-expressions": "error",

			"no-unused-vars": [
				"error",
				{
					vars: "all",
					args: "after-used"
				}
			],

			"no-use-before-define": [
				"error",
				{
					functions: false
				}
			],

			"no-useless-computed-key": "error",
			"no-useless-concat": "error",
			"no-useless-constructor": "error",
			"no-useless-escape": "error",
			"no-useless-rename": "error",
			"no-useless-return": "error",
			"no-void": "error",
			"no-with": "error",
			radix: "error",
			"vars-on-top": "error",
			"wrap-iife": ["error", "any"]
		}
	}
];
