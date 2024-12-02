import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 129, 124, 223), ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int pageIndex = 0;
  late Widget page;

  @override
  Widget build(BuildContext context) {

    switch (pageIndex) {
      case 0:
        page = const ServerPage();

      case 1:
        page = const ClientPage();
      
      default:
        page = const ConfigPage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              backgroundColor: const Color.fromARGB(255, 153, 149, 237),
              selectedIndex: pageIndex,
              extended: false,
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
              ),
              onDestinationSelected: (value) => setState(() {
                pageIndex = value;
              }),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text("server")),
                NavigationRailDestination(icon: Icon(Icons.coffee), label: Text("client")),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text("config")),
              ],
            )
          ),
          Expanded(
            child: page
          )
        ],
      ),
    );
  }
}

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface,

      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Row(
          children: [
            Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              alignment: Alignment.center,
              children: [
                FractionallySizedBox(
                  heightFactor: 0.65,
                        
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset("assets/cat_lamen.png"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      const Icon(Icons.copyright, color: Colors.white24,),
                      const SizedBox(width: 10,),
                      Text("copyright of images for Lylt and Tatsuro Hamada from Pinterest", style: const TextStyle(color: Colors.white38), textScaler: TextScaler.linear(MediaQuery.of(context).size.height / 1700 * 2 ),)
                      
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 60, right: 30),
                
                children: const [
                  Center(child: Text("aaaaa", style: TextStyle(color: Colors.white),)),
                  Divider()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build( BuildContext context ){
    return Container(
      color : Theme.of(context).colorScheme.onSurface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: FractionallySizedBox(
              heightFactor: 0.75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/cat_2.jpg"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      
                      children: [
                        const Text("Ip addres : ", style: TextStyle(color: Colors.white),),
                        const SizedBox( width: 10,),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            style: TextStyle(color: Theme.of(context).colorScheme.surface),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.abcdf:]"))],
                            validator: FormBuilderValidators.ip(errorText: "Please enter a Ipv4 or Ipv6"),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text("port : ",style: TextStyle(color: Colors.white),),
                        const SizedBox( width: 10,),
                        SizedBox(
                          width: 330,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                            style: TextStyle(color: Theme.of(context).colorScheme.surface),
                            validator:FormBuilderValidators.portNumber(errorText: "Please eneter a valid port number")
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tried to connect')),
                          );
                        }
                      },

                      child: const Text("Connect")
                    ),
                  ],
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class CardServer extends StatefulWidget {
  const CardServer({super.key});

  @override
  State<StatefulWidget> createState() => _CardServerState();

}

class _CardServerState extends State<CardServer> {
  bool colorT = true;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(

          dense: true,
          title: const Text('device 0xnfgnn', style: TextStyle(),),
          // trailing : Icon(Icons.more_vert),
          trailing: IconButton(onPressed: (){
              setState(() {
                colorT = !colorT;
              });
            },
            icon: Icon(Icons.done, color: colorT? Colors.red : const Color.fromARGB(255, 149, 189, 254),)),
      ),
    );
  }
}

class _ServerPageState extends State<ServerPage> {
  @override
  Widget build( BuildContext context ){

    Widget catImage = Container(
      constraints: const BoxConstraints(
        maxHeight: 350,
        minHeight: 100,
      ),
    
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset("assets/cat_4.png"),
      ),
    );

    Widget configInfo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/noise_image_1.png"),
                    fit: BoxFit.contain,
                    opacity: 0.02,
                    repeat: ImageRepeat.repeat
                  ),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withAlpha(20),
                ),
                width: 350,
                height: 40,
                clipBehavior: Clip.hardEdge,
                
                child: Material(
                  type: MaterialType.transparency,
                  borderOnForeground: false,
                  borderRadius: BorderRadius.circular(7),
                  child: InkWell(
                    splashColor: const Color.fromARGB(255, 149, 189, 254).withAlpha(100),
                      onTap: (){
                        // need set ip
                        Clipboard.setData(const ClipboardData(text: "Your ip"));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(" The Ip has copied into your clip board"), duration: Durations.medium2,)
                        );
                      }
                      ,
                    child: const Center(child: Text("ip addres", style: TextStyle(color: Colors.white), ))),
                )
                
              ),
              const SizedBox(
                width: 10,
                height: 10,
              ),
          
              // need set ip
              const Text("0000:0000:0000:0000:0000:0000:000:0000", style: TextStyle(color: Colors.white),),
            ],
          ),

          const SizedBox(
                height: 10,
              ),

          Row(
            children: [

              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/noise_image_1.png"),
                    fit: BoxFit.none,
                    opacity: 0.02,
                  ),

                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withAlpha(20),
                ),
                width: 70,
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Material(
                  type: MaterialType.transparency,
                  borderRadius: BorderRadius.circular(7),
                  child: InkWell(
                    splashColor: const Color.fromARGB(255, 149, 189, 254).withAlpha(150),
                    onTap: (){
                      // need set the port
                      Clipboard.setData(const ClipboardData(text: "Your port"));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(" The port has copied into your clip board"), duration: Durations.medium2)
                      );
                    },
                    child: const Center(child: Text("port", style: TextStyle(color: Colors.white),))),
                )
                
              ),

              const SizedBox(
                width: 10,
              ),

              // need set the port
              const Text("2222", style: TextStyle(color: Colors.white),),
            ],
          ),

          const SizedBox(
            height: 20,
          ),
          
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/noise_image_1.png"),
                fit: BoxFit.none,
                opacity: 0.02,
                repeat: ImageRepeat.repeat


              ),

              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(7),
              color: Colors.white.withAlpha(20),
            ),
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),

            child: Column(
              children: [
                const Center(child: Text("devices", style: TextStyle(color: Colors.white),)),
                const SizedBox(
                  height: 10,
                ),

                // need set the devices
                ListView(

                  shrinkWrap: true,
                  children: const [
                    CardServer()
                  ],
                )
              ],
            )
            
          ),
        ] ,
      ),
    );

    return Container(
      color : Theme.of(context).colorScheme.onSurface,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints ){
          if (constraints.maxWidth > 1100){
            return Row(
              children: [
                configInfo,
                Expanded(child: catImage),
              ],
            );
          }

          return ListView(
            // padding: EdgeInsets.all(10),
            children: [
              configInfo,
              catImage,
            ]
          );
        },
      ),
    );
  }
}
