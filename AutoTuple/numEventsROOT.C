int numEventsROOT(char* file){

  TChain *chain = new TChain("Events");
  cout << Form("%s/*.root", file) << endl;
  chain->Add(Form("%s/*.root", file));
  cout << chain->GetEntries() << endl;

}
