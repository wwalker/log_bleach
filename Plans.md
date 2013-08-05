log_bleach - make the cruft disappear from your log files

* auto_tune (put regexes that match the most often earliest in the pattern list)
* multiple files at once support (can easily use xargs in the mean time)

log_bleach log_file_name

* option to specify the filter "level" (so you can choose to leave certain data in the output), 
* option to force-tiemstamp (add timestamps to the output when the input file didn't have timestamps.

log_bleach log_file_source_directory  log_file_target_directory

* for each file under the source directory, filter as above into a matching named extract file in the target directory
* In an ideal world, every file in the target directory would be empty!
* Everything in the filtered extracts is either a bug, or something else to add to the irrelevant filter for that log file type
