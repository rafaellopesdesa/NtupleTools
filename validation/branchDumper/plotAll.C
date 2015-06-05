#pragma GCC diagnostic ignored "-Wwrite-strings"
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#include <fstream>
#include <vector>
#include "TFile.h"
#include "TTree.h"
#include "TList.h"
#include "TString.h"
#include "/home/users/cgeorge/software/dataMCplotMaker/dataMCplotMaker.h"

using namespace std;

int plotAll(){

  TFile *file = new TFile("/hadoop/cms/store/group/snt/phys14/TTJets_MSDecaysCKM_central_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08/merged_ntuple_4.root");
  TTree *tree = (TTree*)file->Get("Events");

  int nEntries = tree->GetEntries();

  TList *t_list = tree->GetListOfAliases();

  for(int i = 0; i < t_list->GetSize(); i++) {
    TString aliasname(t_list->At(i)->GetName());
    cout << aliasname.Data() << endl;
    TString command = aliasname;

    //Support Lorentz Vectors
    TBranch *branch = tree->GetBranch(tree->GetAlias(aliasname.Data()));
    TString branchname(branch->GetName());
    if( branchname.Contains("LorentzVector") ) {
      command.Append(".Pt()");
    }
 
    //Don't support vectors of vectors
    if(branchname.BeginsWith("intss") || branchname.BeginsWith("floatss") || branchname.BeginsWith("doubless") || branchname.Contains("LorentzVectorss") || branchname.Contains("timestamp") ){
      cout << "Sorry, I dont support vector of vectors of objects, will be skipping " << aliasname << endl;
      continue;
    }

    //Don't support TStrings
    if(branchname.Contains("TString") ) {
      cout << "Sorry, I dont support strings, will be skipping " << aliasname << endl;
      continue;
    }

    TString histname = "hist_" + aliasname + ".pdf";
    TH1F* null = new TH1F("","",1,0,1);
    command.Append(">>hist");
    tree->Draw(command.Data(), (aliasname)+"!=-9999 &&"+(aliasname)+"!=-999");
    TH1F *hist = (TH1F*)gDirectory->Get("hist");
    if (hist->Integral() == 0) tree->Draw(command.Data());
    hist = (TH1F*)gDirectory->Get("hist");
    vector <TH1F*> hists; 
    hists.push_back(hist);
    vector <string> titles;
    titles.push_back("");
  
    //Overflow and Underflow
    hist->SetBinContent(1, hist->GetBinContent(1)+hist->GetBinContent(0));
    hist->SetBinContent(hist->GetNbinsX(), hist->GetBinContent(hist->GetNbinsX())+hist->GetBinContent(hist->GetNbinsX()+1));

    if (hist->GetXaxis()->GetXmax() == hist->GetXaxis()->GetXmin()){
      ofstream myfile;
      myfile.open("names.txt", ios_base::app);
      myfile << aliasname.Data() << "\n"; 
      myfile.close();  
    }

    float max = hist->GetMaximum()*100;

    string subtitle = aliasname.Data();
    string histname2 = histname.Data(); 

    dataMCplotMaker(null, hists, titles, subtitle, "CMS3 4.02 Validation", Form("--outputName %s --noFill --noLegend --setMaximum %f --energy 13 --lumi 0 --xAxisLabel %s --noXaxisUnit --noDivisionLabel", subtitle.c_str(), max, histname2.c_str())); 

    delete hist;

  }

    return 0;

}
