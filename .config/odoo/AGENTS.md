## Rules for developement

* Never use `git add/commit/push` unless specifically asked by the user. The user is in charge of git operations.
* The user may edit any file between or during prompts or change changes are staged in git. Those edits are intentional and must be preserved. Ask if you notice inconsistencies.
* When writing new code, try to keep it as minimal as possible. Each line of code is a liability, thus keeping it minimal and readable is extremely important. KISS = Keep it stupid simple.
* No unspecified fallback logic. Silent failures on unexpected inputs are not OK. I.e. avoid adding `try:except` blocks and for well defined API's use `some_dict[key]` instead of `some_dict.get(key)`.
* For changes with any logic, write automated tests. No need to write tests for adding a field to model and normal view, those get tested automatically when the module loads without errors. If automated tests are expected to raise an error, and the module logs it as an ERROR line, use `mute_logger`.
* Tests should NOT assert translatable terms such as display names or other UI strings, as they loading an Odoo db with another language can cause issues with the test.
* Avoid mocks/patches in tests unless it's an API/external call. If it can't be asserted/covered without mocking/patching don't assert it.
* This is a greenfield project, no need to keep backwards compatibility.
* Do not define global variables. Use system parameters or static methods linked to a model instead, as these can be accessed more easily with Odoo's inheritance system.
* Keep business logic inlined instead of adding small helper functions with business code that is not needed elsewhere. It makes code less readable, as we have to keep jumping to definitions. And if the business code changes such that new parameter is needed, all function definitions need to change.
* Never add `from . import tests` into the module root `__init__.py` file. Odoo handles loading tests without this, and the tests should not be loaded on normal server startup.
* Do not create new database cursors in automated tests. If covering a line would require that, mark it with `# pragma: no cover` comment instead.

### Odoo bash tools using the (odoo) helper:

* Check the Odoo help/environment information with command `odoo --help`, and if the command fails, stop immediately and report the error to the user.
* Run the automated tests: `odoo tests`. Note! ALWAYS report the amount of tests after the command finishes (odoo tells it in the logs). If the count is zero, try `odoo install` to install the module first.
* Export Finnish translations: `odoo translate fi`. Note! Never edit the `msgid` values directly, they should always be exported from Odoo. And do not change existing translations if the term is already translated. NOTE2: If HTML code is being exported to the *.po file, add `t-if="True"` to the html element, this way Odoo will not export the HTML node.
* To run arbitrary python code in odoo shell: `odoo shell`
