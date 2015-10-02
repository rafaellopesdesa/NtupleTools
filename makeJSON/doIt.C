int doIt(std::string name){

  gSystem->Load("CORE/CMS3_CORE.so"); 
  gROOT->ProcessLine(".L makeJSON.C+");
  gROOT->ProcessLine(Form("makeJSON(\"%s\")", name.c_str())); 

  return 0;

}
