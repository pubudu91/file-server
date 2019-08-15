import ballerina/http;
import ballerina/system;
import ballerina/openapi;
import ballerina/config;

listener http:Listener ep0 = new(9090, config = {host: "localhost"});

string rootDir = config:getAsString("root.dir", ".");

@openapi:ServiceInfo {
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

}
