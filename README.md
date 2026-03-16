# laughing_dollop

Welcome to the laughing_dollop repo,
here is a example of using the Srt procol on Dart and a usefull application for share native resources like the microphone through **wifi**

## App architecture
  - assets (folder) --> images used on app
  - lib (folder) -- > the src code 
    - native (folder) --> the application use the pipewire to create a virtual mic and retrive audio from the device

## On SRT
The laughing_dollop application offear simples screens to access and configure sockets SRT.
This is possible becuse on start the app the SRT is initilized with a dart-frendely method `initializeSrtFlutter` and pre-configurated with `initializeSRT` - where is created the sockets

### On acess the server page:
  The `server` socket is bounded and start listen for connections

### On acess the client page:
 When insserted a valid ip and port, three sockets are connect into server.
 Each of them for receive microphone data, camera data ( *not imlemented yet* ), and send audio data ( a return of device audio to server - *not imlemented yet* ).
 And registred on `Epoll`

## On Native resource
After the server are initialized a record will get the microphone data and send to client through a handle `micHandle` such that on client the epoll will notify when have a icoming data with the `waitStream` method and send to micrpohone ( through the bindings ).

## Considerations

This app have limitations:
  - platforms availables:
    - linux, client only
    - android, server only

And, both librarys Srt and native/* are in a unstable version, so is expected to have errors like a lantecy of 4s .

New versions are incoming, to fix erros and enchance the user experience.