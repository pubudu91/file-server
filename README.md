# Ballerina File Server
This is a sample file server written in Ballerina. The server can be run to serve files in a specified directory. 

## Running the server
The program takes the directory to serve as an argument. This can be provided either through a config file, an environment variable or as a CLI param.
```
$ ballerina run -e root.dir=dir/to/be/served file_server
```
### Listing the files available
Returns a JSON object array which contains the names of the files available.
```
$ curl http://localhost:9090/files/v1/list
```
### Fetching a file
Returns the specified file. Returns a 404 error if the file could not be found.
```
$ curl http://localhost:9090/files/v1/file/<file-name>
```
