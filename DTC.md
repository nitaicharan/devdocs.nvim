# Install document flow

This method, `M.install`, is responsible for installing documentation for a given entry [1].

- **Line 5:** It checks if the `REGISTERY_PATH` exists [1]. This path likely points to a file or directory that keeps track of available DevDocs documentation sets.
- **Line 6:** If the `REGISTERY_PATH` does not exist, and the `verbose` flag is true, it logs an error message instructing the user to run `:DevdocsFetch` [1]. This suggests that the registry needs to be populated before installation can proceed.
- **Line 8:** It creates an `alias` from the `slug` of the `entry` by replacing tildes ("~") with hyphens ("-") [1]. This likely creates a standardized name for the documentation set.
- **Line 10:** It retrieves a list of already installed documentation aliases [1].
- **Line 12:** It checks if the current `alias` is present in the `installed` list [1].
- **Line 14:** If `is_update` is false (meaning it's a new installation, not an update) and the documentation is already installed (`is_installed` is true), it logs a warning message (if `verbose` is true) indicating that the documentation is already present [1].
- **Line 18:** Otherwise (if it's an update or not already installed), it proceeds with the installation. It retrieves a list of available user interfaces (`uis`) in Neovim [2].
- **Line 20:** It checks if a UI is available (`ui[1]`) and if the database size of the entry (`entry.db_size`) is greater than 10,000,000 bytes (10 MB) [2].
- **Line 22:** If both conditions in line 20 are true, it logs a debug message indicating that the documentation set is large [2].
- **Line 24:** It prompts the user with a confirmation dialog asking if they want to continue building large documentation, as it might freeze Neovim [2].
- **Line 27:** If the user's input is not "y", the function returns, stopping the installation [2].
- **Line 30:** It defines a local `callback` function that takes an `index` as an argument [2, 3]. This callback will be executed after the index file for the documentation is successfully fetched and processed.
- **Line 32:** Inside the `callback`, it constructs the URL (`doc_url`) for the documentation database (a `db.json` file) using the `devdocs_cdn_url`, the `entry.slug`, and the modification time (`entry.mtime`) as a query parameter for cache busting [2].
- **Line 33:** It logs an informational message indicating that it is downloading the documentation for the current `alias` [2].
- **Line 35:** It initiates a GET request using `curl.get` to download the documentation database from `doc_url` [2].
- **Line 36:** It defines a `callback` function that will be executed when the download of the database is successful. This inner callback is wrapped with `vim.schedule_wrap`, ensuring it runs in the main Neovim event loop [4].
- **Line 38:** Inside the inner callback, it decodes the JSON response body (`response.body`) into a Lua table called `docs` [4].
- **Line 39:** It then calls the `build.build_docs` function, passing the `entry`, the fetched `index`, and the downloaded `docs` [4]. This is where the actual building and processing of the documentation content happens.
- **Line 42:** It defines an `on_error` function that will be executed if there is an error during the download of the database. It logs an error message including the `alias` and the error's exit code [4].
- **Line 46:** It constructs the URL (`index_url`) for the documentation index (an `index.json` file) similarly to how the `doc_url` was constructed [4].
- **Line 47:** It logs an informational message indicating that it is fetching the documentation entries for the current `alias` [4].
- **Line 49:** It initiates another GET request using `curl.get` to download the documentation index from `index_url` [4].
- **Line 50:** It defines a `callback` function that will be executed when the download of the index is successful. This callback is also wrapped with `vim.schedule_wrap` [3].
- **Line 52:** Inside this callback, it decodes the JSON response body into a Lua table called `index` [3].
- **Line 54:** It then calls the outer `callback` function (defined in line 30), passing the fetched `index` as an argument [3]. This triggers the download of the actual documentation database after the index is successfully retrieved.
- **Line 57:** It defines an `on_error` function for the index download, similar to the one for the database download, logging an error message with the `alias` and the exit code [3].
- **Line 62:** The `end` keyword closes the `else` block (started at line 16).
- **Line 65:** The final `end` keyword closes the main `M.install` function definition.

**Note on the `build_docs` method:**

This method, `M.build_docs`, is responsible for taking the downloaded documentation data and building the local documentation files [5].

- **Line 8:** It defines the function `M.build_docs` which accepts three parameters: `entry` (information about the documentation set), `doc_index` (an index of the documentation entries), and `docs` (the actual HTML documentation content) [5].
- **Line 10:** It creates an `alias` from the `slug` of the `entry`, similar to the `install` method [5].
- **Line 12:** It defines the directory path (`current_doc_dir`) where the documentation for the current `alias` will be stored, by joining the base `DOCS_DIR` with the `alias` [5].
- **Line 13:** It logs an informational message indicating that it is building the documentation for the current `alias` [5].
- **Line 14:** It checks if the main `DOCS_DIR` exists, and if not, it creates it [5].
- **Line 15:** It checks if the directory for the current documentation (`current_doc_dir`) exists, and if not, it creates it [5].
- **Line 18:** It reads the global index file (likely containing information about all installed documentation sets) or initializes an empty table if the file doesn't exist [6].
- **Line 19:** It reads the lockfile (likely containing metadata about installed documentation) or initializes an empty table if it doesn't exist [6].
- **Line 22:** It initializes an empty table `section_map`. This table will be used to store the available section IDs for each main documentation file [6].
- **Line 23:** It initializes an empty table `path_map`. This table will store the mapping between the original documentation paths (including potential section anchors) and the generated local file paths [6].
- **Line 25:** It iterates through each `index_entry` in the provided `doc_index.entries` [6].
- **Line 26:** It splits the `index_entry.path` by the "#" character. The first part (`main`) is the main file path, and the second part (`id`) is the section identifier (if present) [6].
- **Line 29:** If the `main` file path is not already a key in the `section_map`, it creates a new empty table for it [6].
- **Line 30:** If a section `id` exists, it is added to the list of sections for the corresponding `main` file path in `section_map` [6].
- **Line 34:** It initializes an empty table `sort_lookup`. This table will be used to maintain the original order of documentation entries for sorting purposes [7].
- **Line 35:** It initializes a counter `sort_lookup_last_index` to 1 [7].
- **Line 36:** It initializes a counter `count` to 1. This counter will be used to generate unique filenames for the local documentation files [7].
- **Line 37:** It gets the total number of documents in the `docs` table [7].
- **Line 39:** It iterates through each `doc` (HTML content) in the `docs` table, with `key` being the original filename [7].
- **Line 40:** It logs debug information indicating the progress of the conversion [7].
- **Line 41:** It retrieves the list of section IDs (`sections`) associated with the current `key` from the `section_map` [7].
- **Line 42:** It constructs the local file path (`file_path`) where the converted Markdown content will be written. It uses the `count` as the filename and appends the ".md" extension [7].
- **Line 44:** It attempts to convert the HTML document (`doc`) to Markdown using the `transpiler.html_to_md` function. It also passes the `sections` to help with identifying Markdown sections. `xpcall` is used for error handling during the conversion process [7].
- **Line 44:** `debug.traceback` is provided as an error handler to get a stack trace if the conversion fails [7].
- **Line 46:** If the conversion (`success`) is not successful, it proceeds to log an error message [7].
- **Line 47-51:** The error message includes the original key, the error result (`result`), and the original HTML document (`doc`), instructing the user to report the issue [8].
- **Line 52:** If the conversion fails, the function returns, stopping the build process for this documentation set [8].
- **Line 55:** If the conversion is successful, it iterates through the generated Markdown sections (`md_sections`) [8].
- **Line 56:** For each section, it populates the `path_map` with a mapping from the combined original path (`key` + "#" + `section.id`) to the local file number (`count`) and the section's Markdown path (`section.md_path`) within that file [8].
- **Line 57:** It also populates the `sort_lookup` table with a mapping from the combined original path to the current `sort_lookup_last_index`, effectively recording the original order of sections [8].
- **Line 58:** It increments `sort_lookup_last_index` [8].
- **Line 61:** It populates the `path_map` for the main file path (`key`) with just the file number (`count`). This is used for entries that don't have specific sections [8].
- **Line 62:** It writes the converted Markdown content (`result`) to the `file_path` [8].
- **Line 63:** It increments the `count` for the next file [8].
- **Line 64:** It logs debug information indicating that the file has been written [8].
- **Line 66:** After processing all the HTML documents, it logs a debug message indicating that it's sorting the documentation entries [9].
- **Line 68:** It sorts the `doc_index.entries` table using a custom comparison function [9].
- **Line 69:** The comparison function looks up the sort indices for the paths of two entries (`a` and `b`) in the `sort_lookup` table [9]. If an entry's path is not found, it defaults to -1.
- **Line 72:** The entries are sorted based on their original order as recorded in `sort_lookup` [9].
- **Line 73:** It logs a debug message indicating that it's filling the documentation links and paths [9].
- **Line 75:** It iterates through the sorted `doc_index.entries` [9].
- **Line 76:** It extracts the main file path from the `index_entry.path` [9].
- **Line 77:** It sets the `link` property of the current `index_entry` to its original path [9].
- **Line 78:** It sets the `path` property of the current `index_entry` to the corresponding local file path (with optional section information) retrieved from the `path_map`. If a specific path with a section is not found, it defaults to the path of the main file [9].
- **Line 81:** It updates the main `index` table with the processed `doc_index` for the current `alias` [9].
- **Line 82:** It updates the `lockfile` with the current `entry` [9].
- **Line 84:** It writes the updated `index` table back to disk [10].
- **Line 85:** It writes the updated `lockfile` back to disk [10].
- **Line 86:** It logs an informational message indicating that the build process is complete [10].
- **Line 89:** The final `end` and `return M` complete the `M.build_docs` function definition and return the module `M` [10].
