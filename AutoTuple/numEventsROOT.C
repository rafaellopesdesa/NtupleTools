void numEventsROOT(std::string file){

  TChain *chain = new TChain("Events");
  cout << Form("%s/*.root", file.c_str()) << endl;
  chain->Add(Form("%s/*.root", file.c_str()));
  cout << file << " nEntries: " << chain->GetEntries() << endl;

}
