
require! {
    fs
    '@iarna/toml': toml
}

"Welcome to Unagi!" |> console.log

"""Select an option:
[1] -> add a script
[2] -> remove a script
[3] -> map an incoming JSON structure to a service
[4] -> map an outgoing JSON structure to a service
[5] -> see everything under a service
[6] -> see a specific part of a service
""" |> console.log

input = (fs.read-file-sync 0, \utf-8).trim!

throw new Error 'Invalid Input given; that command does not exist' unless input in <[1 2 3 4 5 6]>

unagiToml = "unagi.toml"

readToml = () ->
    (fs.read-file-sync unagiToml, \utf-8) |> toml.parse

speakThenListen = (message) ->
    console.log message
    fs.read-file-sync 0, \utf-8


addScript = () ->
    current-toml = readToml!
    service-given = speakThenListen("What is the name of this service?")
    script-given = speakThenListen("What script do you want to use to boot up this service?") # I'll add file linking later, but for now a string literal is required.
    port-given = speakThenListen("What port do you want this service to live on?")

    for service in current-toml.services
        if service.service_name == service-given then throw new Error 'A service under this name already exists'
        if service.port == port-given            then throw new Error 'Conflict: an existing service already lives on this port'

    new-script =
        service-name: service-given
        script: script-given
        port: port-given
        data-in: ""
        data-out: ""


    
    current-toml.services.push |< toml.stringify new-script 
    fs.write-file-sync unagiToml, current-toml

    
    "Successfully added the service #service-given. You can view its data in unagi.toml" |> console.log

removeScript = () ->
    current-toml = readToml!
    
    service-to-remove = speakThenListen("What service do you want to remove?")
    return "No service of the name #service-to-remove exists." unless current-toml.servies.some (-> it.service-name == service-to-remove)

    confirmation = speakThenListen("Are you sure you would like to remove the service #service-to-remove? Y/n")
    return unless confirmation == 'Y'

    clean-services-list = []
    for service in current-toml.services
        clean-services-list.push, service unless service.service-name == service-to-remove
    
    current-toml.services = clean-services-list
    toml.stringify current-toml |> fs.write-file-sync unagiToml, _


switch input
| \1 => addScript!
| \2 => removeScript!
| otherwise => throw new Error 'Work in progress'

# more features will be added later

