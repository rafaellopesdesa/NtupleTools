#include "TH1F.h"
#include "TH2F.h"
#include "TFile.h"
#include "TClass.h"
#include "TKey.h"
#include "TTree.h"
#include "TCanvas.h"
#include "TVirtualPad.h"
#include "TPaveText.h"
#include "TString.h"
#include "TStyle.h"
#include "TLegend.h"
#include <fstream>
#include <algorithm>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

vector<TString> getAliasNames(TTree *t){

  vector<TString> v_aliasnames;
  if (t->GetEntriesFast() == 0) return v_aliasnames;
  
  TList *t_list =  t->GetListOfAliases();
  for(int i = 0; i < t_list->GetSize(); i++) {
    TString aliasname(t_list->At(i)->GetName());
    TBranch *branch = t->GetBranch(t->GetAlias(aliasname.Data()));
    TString branchname(branch->GetName());
    TString branchtitle(branch->GetTitle());

    if(branchname.BeginsWith("intss") ||
       branchname.BeginsWith("floatss") ||
       branchname.BeginsWith("doubless") ||
       branchname.Contains("LorentzVectorss") ||
       branchname.Contains("timestamp") ) {
      
      cout << "Sorry, I dont know about vector of vectors of objects. " << "Will be skipping " << aliasname << endl;
      
      continue;
    }

    if(branchname.Contains("TString") ) {
      cout << "Sorry, I don't know how to graphically represent TStrings in only 3 dimensions" << " Put in a feature request. Will be skipping " << aliasname << endl;
      continue;
    }
    v_aliasnames.push_back(aliasname);
  }

  sort(v_aliasnames.begin(), v_aliasnames.end());
  
  return v_aliasnames;
}

//----------------------------------------------------------------------
bool areHistosTheSame(TH1F* h1, TH1F* h2){
  
  if(h1->GetNbinsX() != h2->GetNbinsX()) return false;
  
  //make sure that the bin range is the same
  float range1 = h1->GetBinCenter(1) - h1->GetBinCenter(h1->GetNbinsX());
  float range2 = h2->GetBinCenter(1) - h2->GetBinCenter(h2->GetNbinsX());

  if(TMath::Abs(range1 - range2) > 0.000001) return false;
  
  float chi2 = h1->Chi2Test(h2, "WWNORM");
  std::cout << " chi2: " << chi2 << std::endl;
  return chi2 > 0.95;
}

//-----------------------------------------------------------------------
vector<TString> getUncommonBranches(vector<TString> aliasnames, vector<TString> v_commonBranches){
  
  vector<TString>  v_notCommonBranches;
  for(vector<TString>::iterator it = aliasnames.begin();
      it != aliasnames.end(); it++) {
    if(find(v_commonBranches.begin(), v_commonBranches.end(), *it) != v_commonBranches.end())
      continue;
    v_notCommonBranches.push_back(*it);
  }

  sort(v_notCommonBranches.begin(), v_notCommonBranches.end());

  return v_notCommonBranches;

}

//-----------------------------------------------------------------------
void compareNtuples(TString file1, TString file2, bool doNotSaveSameHistos="true", bool drawWithErrors="true"){

  gStyle->SetOptStat(0); 
  
  cout << "Starting" << endl;
  TLegend *leg = new TLegend(0.7, 0.79, 0.92, 0.87); 
  TLegend *lega = new TLegend(0.7, 0.79, 0.92, 0.87); 
  TLegend *legb = new TLegend(0.7, 0.79, 0.92, 0.87); 
  leg->SetFillStyle(0);
  leg->SetBorderSize(0);
  lega->SetFillStyle(0);
  lega->SetBorderSize(0);
  legb->SetFillStyle(0);
  legb->SetBorderSize(0);
  
  TFile *f1 = TFile::Open(file1.Data(), "READ");
  if(f1 == NULL) {
    cout << "Exiting" << endl;
    return;
  }
  TTree *tree1 = (TTree*)f1->Get("Events");
  if(tree1 == NULL) {
    cout << "Can't find the tree \"Events\" in " << file1 << " Exiting " << endl;
    return;
  }

  TFile *f2 = TFile::Open(file2.Data(), "READ");
  if(f2 == NULL) {
    cout << "Exiting" << endl;
    return;
  }
  TTree *tree2 = (TTree*)f2->Get("Events");
  if(tree2 == NULL) {
    cout << "Can't find the tree \"Events\" in " << file2 << " Exiting " << endl;
    return;
  }

  TObjArray *objArray= file1.Tokenize("/");
  TString fname1 = "";
  TString fname2 = "";
  for(int i = 0; i < objArray->GetSize(); i++) {
    if(fname1 != "")
      continue;
    cout << TString(objArray->At(i)->GetName()) << endl;
    if(TString(objArray->At(i)->GetName()).Contains("root")) {
      fname1 = TString(objArray->At(i)->GetName());
      continue;
    }
  }
  objArray = file2.Tokenize("/"); 
  for(int i = 0; i < objArray->GetSize(); i++) {
    if(fname2 != "")
      continue;
    cout << TString(objArray->At(i)->GetName()) << endl;
    if(TString(objArray->At(i)->GetName()).Contains("root")) {
      fname2 = TString(objArray->At(i)->GetName());
      continue;
    }
  }
  
  vector<TString> t1_aliasnames = getAliasNames(tree1);
  vector<TString> t2_aliasnames = getAliasNames(tree2);
  vector<TString> v_commonBranches;
  vector<TString> v1_notCommonBranches;
  vector<TString> v2_notCommonBranches;
  
  for(vector<TString>::iterator it = t1_aliasnames.begin(); it != t1_aliasnames.end(); it++) {
    if(find(t2_aliasnames.begin(), t2_aliasnames.end(), *it) != t2_aliasnames.end()) v_commonBranches.push_back(*it);
  }

  //figure out which branches are not common so you can output their names and draw them last
  v1_notCommonBranches = getUncommonBranches(t1_aliasnames, v_commonBranches);
  v2_notCommonBranches = getUncommonBranches(t2_aliasnames, v_commonBranches);

  TCanvas *c1 = new TCanvas();

  int nEntries = min(tree1->GetEntries(), tree2->GetEntries()); 

  ofstream myfile; 
  myfile.open("overview.tex"); 
  myfile << "\\documentclass{article}" << endl
         << "\\usepackage{fullpage}" << endl
         << "\\begin{document}" << endl
         << "The following were found in OLD but not in NEW:" << endl 
         << "\\begin{itemize}" << endl;
  for(unsigned int i = 0; i < v1_notCommonBranches.size(); i++) {

    TString alias = v1_notCommonBranches.at(i);
    if (nEntries != 0) myfile << "\\item " << alias << endl;
    TString histname = "h1_"+(alias);
    TString command  = (alias) + ">>" + histname;
    TBranch *branch = tree1->GetBranch(tree1->GetAlias(alias));
    TString branchname(branch->GetName());
    
    if( branchname.Contains("LorentzVector") ) {
      histname = "h1_"+ alias + "_pt";
      command  = alias + ".Pt()>>" + histname;      
    }
    tree1->Draw(command.Data());
    TH1F *h1 = (TH1F*)gDirectory->Get(histname.Data());
    if(h1==NULL) {
      cout << "********** Branch " << v1_notCommonBranches.at(i) 
       << " in file " << file1 << "exists, but is undrawable for some reason. " 
       << "Skipping this branch" << endl;
      c1->Clear();
      continue; 
    }
    c1->Clear();

    if(drawWithErrors) h1->TH1F::Sumw2();
    
    h1->Scale(1./h1->GetEntries());
    if(!drawWithErrors) {
      h1->SetLineColor(0);
      h1->SetMarkerSize(1.1);
      h1->SetMarkerStyle(3);
    } 
    else {
      h1->SetMarkerSize(1.3);
      h1->SetMarkerStyle(3);
    }
    if (lega->GetNRows() < 1) lega->AddEntry(h1, "old", "l");
    
    h1->SetTitle(v1_notCommonBranches.at(i));
    h1->Draw();
    lega->Draw();
    c1->Print("hist.pdf"); 

    for(int ii = 0; ii < c1->GetListOfPrimitives()->GetSize(); ii++) {
      if(string(c1->GetListOfPrimitives()->At(ii)->ClassName()) != "TVirtualPad") continue;
      TVirtualPad *vPad = (TVirtualPad*)(c1->GetListOfPrimitives()->At(ii));
      if(vPad != NULL) vPad->SetLogy();
    }
    c1->SaveAs("diff.ps(");
    c1->SetLogy(0);
  }
  myfile << "\\end{itemize}" << endl
         << "The following were found in NEW but not in OLD:" << endl 
         << "\\begin{itemize}" << endl;

  for(unsigned int i = 0; i < v2_notCommonBranches.size(); i++) {
    
    TString alias = v2_notCommonBranches.at(i);
    if (nEntries != 0) myfile << "\\item " << alias << endl;
    TString histname = "h2_"+(alias);
    TString command  = (alias) + ">>" + histname;
    TBranch *branch = tree2->GetBranch(tree2->GetAlias(alias));
    TString branchname(branch->GetName());
    
    if( branchname.Contains("LorentzVector") ) {
      histname = "h2_"+ alias + "_pt";
      command  = alias + ".Pt()>>" + histname;      
    }
    tree2->Draw(command.Data());
    TH1F *h2 = (TH1F*)gDirectory->Get(histname.Data());
    if(h2==NULL) {
      cout << "********** Branch " << v2_notCommonBranches.at(i) 
       << " in file " << file2 << "exists, but is undrawable for some reason. " 
       << "Skipping this branch" << endl;
      c1->Clear();
      continue; 
    }
    c1->Clear();

    if(drawWithErrors)
      h2->TH1F::Sumw2();


    h2->Scale(1./h2->GetEntries());
    
    if(!drawWithErrors) {
      h2->SetLineColor(kRed);
    } else {
      h2->SetMarkerSize(1.1);
      h2->SetMarkerStyle(8);
      h2->SetMarkerColor(kRed);
    }
    if (legb->GetNRows() < 1) legb->AddEntry(h2, "new", "l");
    h2->SetTitle(v2_notCommonBranches.at(i));
    h2->Draw();
    legb->Draw();
    for(int ii = 0; ii < c1->GetListOfPrimitives()->GetSize(); ii++) {
      if(string(c1->GetListOfPrimitives()->At(ii)->ClassName()) != "TVirtualPad")
    continue;
      TVirtualPad *vPad = (TVirtualPad*)c1->GetListOfPrimitives()->At(ii);
      if(vPad != NULL)
    vPad->SetLogy();
    }
    c1->SaveAs("diff.ps(");
    c1->SetLogy(0);
  }
  myfile << "\\end{itemize}" << endl
         << "\\end{document}" << endl;

  for(unsigned int i =  0; i < v_commonBranches.size(); i++) {
  
    TString alias = v_commonBranches.at(i);
    cout << "Comparing Branch: " << alias << endl;
    TString hist1name = "h1_"+ alias;
    TString hist2name = "h2_"+ alias;
    TString command1 = (alias)+"+9990.*((abs("+alias +"+9999)<1)*1.)>>"+hist1name;
    TString command2 = (alias)+"+9990.*((abs("+alias +"+9999)<1)*1.)>>"+hist2name;
    TBranch *branch = tree2->GetBranch(tree2->GetAlias(alias));
    TString branchname(branch->GetName());
        
    if(branchname.Contains("p4") ) {
      hist1name = "h1_"+ alias + "_Pt";
      hist2name = "h2_"+ alias + "_Pt";
      command1 = alias + ".pt()+14130.*((abs("+alias+".pt()-14140.7)<1)*1.)>>"+hist1name;
      command2 = alias + ".pt()+14130.*((abs("+alias+".pt()-14140.7)<1)*1.)>>"+hist2name;
    }
    
    tree1->Draw(command1.Data());
    TH1F *h1 = (TH1F*)gDirectory->Get(hist1name.Data());
    if(h1==NULL) {
      cout << "********** Branch " << v_commonBranches.at(i) 
       << " in file " << file1 << " exists, but is undrawable for some reason. " 
       << "Skipping this branch" << endl;
      c1->Clear();
      continue; 
    }
    tree2->Draw(command2.Data());
    TH1F *h2 = (TH1F*)gDirectory->Get(hist2name.Data());
    if(h2==NULL) {
      cout << "********** Branch " << v_commonBranches.at(i) 
       << " in file " << file2 << "exists, but is undrawable for some reason. " 
       << "Skipping this branch" << endl;
      c1->Clear();
      continue;  
    }
    c1->Clear();

    h1->Scale(1./h1->GetEntries());
    h2->Scale(1./h2->GetEntries());
    
    bool histos_theSame = areHistosTheSame(h1, h2);
    if(histos_theSame && doNotSaveSameHistos){
      cout << "  SKIPPING!  Identical." << endl;
      continue;
    }
    
    if (!histos_theSame){
      double min1 = h1->GetXaxis()->GetXmin();
      double min2 = h2->GetXaxis()->GetXmin(); 
      double max1 = h1->GetXaxis()->GetXmax();
      double max2 = h2->GetXaxis()->GetXmax();

      double hmin = min1 > min2 ? min2 : min1;
      double hmax = max1 > max2 ? max1 : max2;

      command1 += Form("_fix(100,%f,%f)", hmin, hmax);
      command2 += Form("_fix(100,%f,%f)", hmin, hmax);
      hist1name += "_fix";
      hist2name += "_fix";
      tree1->Draw(command1.Data());
      tree2->Draw(command2.Data());
      h1 = (TH1F*)gDirectory->Get(hist1name.Data());
      h2 = (TH1F*)gDirectory->Get(hist2name.Data());
      h1->Scale(1./h1->GetEntries());
      h2->Scale(1./h2->GetEntries());
      if (leg->GetNRows() < 2) leg->AddEntry(h1, "old", "p");
      if (leg->GetNRows() < 2) leg->AddEntry(h2, "new", "l");
      h2->SetTitle(v_commonBranches.at(i));
      h1->SetTitle(v_commonBranches.at(i));
   }

    if(drawWithErrors) {
      h1->TH1F::Sumw2();
      h2->TH1F::Sumw2();
    }

    double bDiff = 0;
    unsigned int nX1 = h1->GetNbinsX();
    for(unsigned int iB=0; iB<=nX1+1; ++iB){
      if(h1->GetBinError(iB)==0 && h1->GetBinContent(iB)!=0) h1->SetBinError(iB,1e-3*fabs(h1->GetBinContent(iB)));
      if(h2->GetBinError(iB)==0 && h2->GetBinContent(iB)!=0) h2->SetBinError(iB,1e-3*fabs(h2->GetBinContent(iB)));
      bDiff +=fabs(h1->GetBinContent(iB) - h2->GetBinContent(iB));
    }

    if(h1->GetMaximum() >= h2->GetMaximum()) {
      
      double max = 1.1*h1->GetMaximum();
      h1->SetMaximum(max);
      h2->SetMaximum(max);
        
      if(!drawWithErrors){
        h1->SetLineColor(0);
        h1->SetMarkerSize(1.1);
        h1->SetMarkerStyle(3);
        h2->SetLineColor(kRed);
        h2->Draw();
        h1->Draw("SAMEh*");
        leg->Draw();
      } 
      else {
        h1->SetMarkerSize(1.3);
        h1->SetMarkerStyle(3);
        h2->SetMarkerSize(1.1);
        h2->SetMarkerStyle(8);
        h2->SetMarkerColor(kRed);
        h2->Draw("e");
        h1->Draw("samee");
        leg->Draw();
      }
    } 
    else {
      double max = 1.1*h2->GetMaximum();
      h1->SetMaximum(max);
      h2->SetMaximum(max);
      
      if(!drawWithErrors) {
        h1->SetLineColor(kBlue);
        h1->SetMarkerSize(1.1);
        h1->SetMarkerStyle(3);
        h2->SetLineColor(kRed);
        h1->Draw("h*");
        h2->Draw("SAME");
        leg->Draw();
      } 
      else {
        h1->SetMarkerSize(1.3);
        h1->SetMarkerStyle(3);
        h2->SetMarkerSize(1.1);
        h2->SetMarkerStyle(8);
        h2->SetMarkerColor(kRed);
        TString histtitle = v_commonBranches.at(i);
        h1->Draw("e");
        h2->Draw("samese");
        leg->Draw();
      }

    }
    c1->SaveAs("diff.ps("); 
      
    if(i < v_commonBranches.size() - 1) {
	  c1->SetLogy();
	  for(int ii = 0; ii < c1->GetListOfPrimitives()->GetSize(); ii++) {
	    if(string(c1->GetListOfPrimitives()->At(ii)->ClassName()) != "TVirtualPad") continue;
	    TVirtualPad *vPad = (TVirtualPad*)c1->GetListOfPrimitives()->At(ii);
	    if(vPad != NULL) vPad->SetLogy();
	  }
	  c1->SetLogy(0);
    } 
    else {
	  cout << "done" << endl;
	  c1->SetLogy();
	  for(int ii = 0; ii < c1->GetListOfPrimitives()->GetSize(); ii++) {
	    if(string(c1->GetListOfPrimitives()->At(ii)->ClassName()) != "TVirtualPad") continue;
	    TVirtualPad *vPad = (TVirtualPad*)c1->GetListOfPrimitives()->At(ii);
	    if(vPad != NULL) vPad->SetLogy();
	  }
	  c1->SetLogy(0);
    }
      
  }//for loop
}
