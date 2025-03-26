import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool hasPermuission=false;
  bool isflashon= false; 

  late MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
    _checkpermission();
  }
  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
Future<void> _checkpermission()async{
  final status = await Permission.camera.request();
  setState(() {
    hasPermuission=status.isGranted;
  });
}
 Future<void> _processScannerData(String ? data) async{
  if(data == null) return;

  scannerController.stop();

  String type = "text";
  if(data.startsWith("BEGIN:VCARD")){
    scannerController.stop();
    String type="text";
    if(data.startsWith( "BEGIN:VCARD")){
      type ="Contact";
      
    }
    else if (data.startsWith('http://')||data.startsWith('http://')){
      type = 'url';
    }
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
     builder: (context)=> DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context,controller)=> Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top:Radius.circular(24) )
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
            ),),
            Text("Scanned result:",
            style: Theme.of(context).textTheme.headlineSmall,
            
            ), 
            SizedBox(height: 16,),
            Text('type:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            ),
            SizedBox(height: 16,),
            Expanded(child: SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(data,
                  style: Theme.of(context).textTheme.bodyLarge,),
                  SizedBox(
                    height: 24,
                  ),
                  if(type == 'url')
                    ElevatedButton.icon(
                      onPressed: (){},
                      icon: Icon(Icons.open_in_new),
                       label: Text('Open URL'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                    ), 
                     if(type == 'contact')
                    ElevatedButton.icon(
                      onPressed: (){
                        //save contact data
                      },
                      icon: Icon(Icons.open_in_new),

                       label: Text('Save Contact'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                    ), 
                  
                  
                ],

              ),
            )),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed:  (){
                  Share.share(data);
                },
                icon: Icon(Icons.share),
                 label: Text("Share"),
                 ),
                 ),
                 SizedBox(
                  height: 16,
                 ),
                  Expanded(child: OutlinedButton.icon(onPressed:  (){
                    Navigator.pop(context);
                },
                icon: Icon(Icons.qr_code_scanner),
                 label: Text("Scan Again"), 
                 ),
                 ),
              ],
            )
          ],
        ),
      ),
     ),
    );
      }
 }
 Future<void> _launchURL(String url) async{
  if(await canLaunchUrl(Uri.parse(url))){
    await launchUrl(Uri.parse(url));
  }
 }


 Future<void> _saveContact(String vcardData)async{
  final lines = vcardData.split('\n');
  String? name, phone, email;
    for(var line in lines){
      if ( line.startsWith('FN:')) name=line.substring(3);
      if ( line.startsWith('TEL:')) phone=line.substring(4);

      if ( line.startsWith('EMAIL:')) email=line.substring(5);

    }
    final contact = contacts.Contact ()
    ..name.first= name ?? ''
    ..phones = [contacts.Phone(phone ?? '')];
        // ..emails = [contacts.emails(email ?? '')];
    try
      {
        await contact.insert();
      ScaffoldMessenger
      .of(context)
      .showSnackBar(SnackBar(content: Text("Contact saved!")),
      );
      }catch(e){
 ScaffoldMessenger
      .of(context)
      .showSnackBar(SnackBar(content: Text("Failed")),
      );
      }
      
      
    


 }
  @override
  Widget build(BuildContext context) {
    //if condition is...not granted
    if(!hasPermuission){
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Scanner"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 350,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(padding: EdgeInsets.all(30),
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
   Icon(
    Icons.camera_alt_outlined,
    size: 64,
    color: Colors.grey,
   )  ,
   SizedBox(
height: 16,
   ) ,
   Text("Camera permission is required"),
   SizedBox(
    height: 16,
   ),
   ElevatedButton(
           child: Text("Grand permission"),

    onPressed: _checkpermission,
   style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,

   ),
   )         
          ],
                 ),

                  ),
                ),
              ),
            )
          ],
        ),
      );
      }else{
        return Scaffold(
   //if condition is granted
    backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text("Scaning QR code",style: GoogleFonts.poppins(
               fontSize: 18,fontWeight: FontWeight.bold,
          ),),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: (){

              setState(() {
                isflashon = !isflashon;
                scannerController.toggleTorch();
              });
            }, icon: Icon(isflashon ? Icons.flash_on : Icons.flash_off),)
          ],
        ),
        body: Stack(
          //camera propose
          children: [
            MobileScanner(
              controller: scannerController,
              onDetect: (capture){
                final barcode = capture.barcodes.first;
                if(barcode.rawValue != null){
                  final String code = barcode.rawValue!;
                  _processScannerData(code);
                }
              },
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: Text("Align QR within the frame",style: GoogleFonts.poppins(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),),),
            )
          ],
        ),
        );
      }
  }
}