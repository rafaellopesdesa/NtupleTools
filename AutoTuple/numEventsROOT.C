int numEventsROOT(char* file){

  TChain *chain = new TChain("Events");
  cout << Form("/hadoop/cms/store/group/snt/phys14/%s/*.root", file) << endl;
  chain->Add(Form("/hadoop/cms/store/group/snt/phys14/%s/*.root", file));
  cout << chain->GetEntries() << endl;

}
