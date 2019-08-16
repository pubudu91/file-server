import ballerina/http;
import ballerina/system;
import ballerina/openapi;
import ballerina/config;
import ballerina/io;
import ballerina/log;
import ballerina/filepath;

listener http:Listener ep0 = new(9090, config = {host: "localhost"});

string rootDir = config:getAsString("\"root.dir\"", ".");

@openapi:ServiceInfo {
    // Replace this with the absolute path. Due to https://github.com/ballerina-platform/ballerina-lang/issues/17834
    contract: "/home/pubudu/testing/ballerina/1.0/beta-test/file-server/src/file_server/resources/file-server.yaml" 
}
@http:ServiceConfig {
    basePath: "/files/v1"
}
service fileService on ep0 {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/list"
    }
    resource function listfiles(http:Caller caller, http:Request req) returns error? {
        system:FileInfo[] fileList = checkpanic system:readDir(rootDir);
        File[] files = [];
        int i = 0;

        fileList.forEach(function (system:FileInfo info) {
            files[i] = {name: info.getName()};
            i += 1;
        });

        json[] respPayload = checkpanic json[].constructFrom(files);

        var result = caller->respond(respPayload);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/file/{filename}"
    }
    resource function getFile(http:Caller caller, http:Request req, string filename) returns error? {
        var byteChannel = io:openReadableFile(getAbsolutePath(filename));

        if (byteChannel is io:ReadableByteChannel) {
            var result = caller->respond(<@untainted>byteChannel);
            if (result is error) {
                log:printError("failed to respond", result);
            }
        } else {
            log:printError("failed to open file", byteChannel);

            http:Response fileNotFound = new;
            fileNotFound.statusCode = http:STATUS_NOT_FOUND;
            json errMsg = {"message":"File not found", "filename":<@untainted>filename};
            fileNotFound.setPayload(errMsg);
            
            var result = caller->respond(fileNotFound);
            

            if (result is error) {
                log:printError("failed to respond", result);
            }
        }
    }
}

function getAbsolutePath(string filename) returns @untainted string {
    return checkpanic filepath:build(rootDir, <@untainted>filename);
}
