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
    contract: "./resources/file-server.yaml"
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
            var result = caller->respond(<@untainted>byteChannel.reason());
            log:printError("failed to respond", byteChannel);
        }
    }
}

function getAbsolutePath(string filename) returns @untainted string {
    return checkpanic filepath:build(rootDir, <@untainted>filename);
}
