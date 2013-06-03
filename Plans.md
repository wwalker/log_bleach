log_bleach - make the cruft disappear from your log files

* compression support
* auto_tune (put regexes that match the most often earliest in the pattern list)
* editor
* multiple files at once support (can easily use xargs in the mean time)
* rails support (a decolorization input filter so things will match, no I will NOT put the color back in the output stream)
* currently require ruby, and perl+YAML; should require only one language.
+ that language will be perl as it's ubiquitous

log_bleach log_file_name

* option to specify the filter "level" (so you can choose to leave certain data in the output), 
* option to force-tiemstamp (add timestamps to the output when the input file didn't have timestamps.

log_bleach log_file_source_directory  log_file_target_directory

* for each file under the source directory, filter as above into a matching named extract file in the target directory
* In an ideal world, every file in the target directory would be empty!
* Everything in the filtered extracts is either a bug, or something else to add to the irrelevant filter for that log file type
