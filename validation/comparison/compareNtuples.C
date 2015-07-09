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
#include "/home/users/sicheng/tas/Software/dataMCplotMaker/dataMCplotMaker.h"

using namespace std;

bool comparePair(const std::pair<float, int> & a, const std::pair<float, int> & b) {
  return a.first < b.first;
}

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
      
      cout << "Sorry, I dont know about vector of vectors of objects. Will be skipping " << aliasname << endl;
      
      continue;
    }

    if(branchname.Contains("TString") ) {
      cout << "Sorry, I don't know how to graphically represent TStrings in only 3 dimensions."
           << " Put in a feature request. Will be skipping " << aliasname << endl;
      continue;
    }
    v_aliasnames.push_back(aliasname);
  }

  sort(v_aliasnames.begin(), v_aliasnames.end());
  
  return v_aliasnames;
}

//----------------------------------------------------------------------
float Chi2ofHistos(TH1F* h1, TH1F* h2){

  if(h1->GetNbinsX() != h2->GetNbinsX()) return -2;
  
  //make sure that the bin range is the same
  float range1 = h1->GetBinCenter(1) - h1->GetBinCenter(h1->GetNbinsX());
  float range2 = h2->GetBinCenter(1) - h2->GetBinCenter(h2->GetNbinsX());

  if(TMath::Abs(range1 - range2) > 0.000001) return -1;
 
  float prob = h1->Chi2Test(h2, "WWNORM"); // = 1 if consistent, = 0 if inconsistent 

  //if there is 1 filled bin, chi2test returns 0, so we manually find and compare this bin
  if(prob < 0.0001) {
      int nNonZeroBins = 0;
      int iNonZeroBin  = 0;
      for(int i = 1; i < h1->GetNbinsX()+1; i++) {
          if(nNonZeroBins > 1) break;
          if(h1->GetBinContent(i) > 0.0 && h2->GetBinContent(i) > 0.0 ) {
              nNonZeroBins += 1;
              iNonZeroBin = i;
          }
      }
      if(nNonZeroBins == 1) {
          // check if the single bin that has entries is within 1% between h1 and h2
          if( 1.0*(h1->GetBinContent(iNonZeroBin)-h2->GetBinContent(iNonZeroBin))/h1->GetBinContent(iNonZeroBin) < 0.01 ) prob = 0.99;
      }
  }
  return prob;
  
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
void compareNtuples(TString file1, TString file2, bool doNotSaveSameHistos="true", bool drawWithErrors="true", float idThreshold=0.99)
{
  gStyle->SetOptStat(0); 
  cout << "Starting" << endl;
  
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

  TH1F* empty = new TH1F("","", 60,0,60);
  int plotNum = 0;
  
  ofstream myfile; 
  myfile.open("overview.tex"); 
  myfile << "\\documentclass{article}" << endl
         << "\\usepackage{fullpage}" << endl
         << "\\usepackage{graphicx}" << endl
         << "\\usepackage{float}" << endl
         << "\\usepackage{listings}" << endl
         << "\\usepackage{hyperref}" << endl << endl

         << "\\begin{document}" << endl << endl

         << "\\begin{center}" << endl
         << "\\LARGE \\bf Compare Ntuples for CMS3" << endl
         << "\\end{center}" << endl
         << "\\vspace{0.5cm}" << endl << endl

         << "{\\noindent\\Large\\bf Files that are compared here:}" << endl
         << "\\begin{lstlisting}[breaklines] "  << endl
         << "OLD: " << file1 << endl
         << "NEW: " << file2 << endl
         << "\\end{lstlisting}" << endl
         << "\\vspace{0.5cm}" << endl << endl 
    
         << "\\tableofcontents" << endl 
         << "\\section*{Branches in OLD but not in NEW}\\addcontentsline{toc}{section}{Branches in Old but not in New}" << endl;

  for(unsigned int i = 0; i < v1_notCommonBranches.size(); i++) { 

    TString alias = v1_notCommonBranches.at(i);
    myfile << "\\subsection*{" << alias << "}\\addcontentsline{toc}{subsection}{" << alias << "}" << endl;
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

    h1->Scale(1./h1->GetEntries());

    vector<TH1F*> hvec;
    hvec.push_back(h1);
    vector<string> titles;
    titles.push_back("Old");
    dataMCplotMaker(empty, hvec, titles, "", alias.Data(), Form("--isLinear --noDivisionLabel --xAxisOverride --outputName hists/uncommon%d", plotNum));
    myfile << "\\begin{figure}[H]" << endl
           << Form("\\includegraphics[width=0.6\\textwidth]{./hists/uncommon%d.pdf}", plotNum) << endl
           << "\\end{figure}" << endl;
    plotNum++;
  }
  if(v1_notCommonBranches.size() == 0) myfile << "There is no branch that found in OLD but not in NEW" << endl;
  
  myfile << "\\section*{Branches in NEW but not in OLD}\\addcontentsline{toc}{section}{Branches in New but not in Old}" << endl;

  for(unsigned int i = 0; i < v2_notCommonBranches.size(); i++) {
    
    TString alias = v2_notCommonBranches.at(i);
    myfile << "\\subsection*{" << alias << "}\\addcontentsline{toc}{subsection}{" << alias << "}" << endl;
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

    h2->Scale(1./h2->GetEntries());

    vector<TH1F*> hvec;
    hvec.push_back(h2);
    vector<string> titles;
    titles.push_back("New");
    dataMCplotMaker(empty, hvec, titles, "", alias.Data(), Form("--isLinear --xAxisOverride --noDivisionLabel --outputName hists/uncommon%d", plotNum));
    myfile << "\\begin{figure}[H]" << endl
           << Form("\\includegraphics[width=0.6\\textwidth]{./hists/uncommon%d.pdf}", plotNum) << endl
           << "\\end{figure}" << endl;
    plotNum++;
  }
  if(v2_notCommonBranches.size() == 0) myfile << "There is no branch that found in NEW but not in OLD" << endl;

  myfile << "\\section*{Branches in Common}\\addcontentsline{toc}{section}{Branches in Common}" << endl;

  vector< pair<float,int> > chi2pair;
  int bingo = 0;
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

    float chi2 = Chi2ofHistos(h1, h2);
    // if(chi2 > 0.999)  myfile << "Branch has native good chi2: " <<  alias << "   " << chi2 << "\\\\\n";
    
    // float chi2new = -1;
    // bool wrongBin = false;

    // if(chi2 == -1 ){
    //   myfile << "Branch " << alias << " has problem with binning: " << chi2 << "\\\\\n";
    //   continue;
    // }
    if(chi2 > idThreshold && doNotSaveSameHistos){
      cout << "  SKIPPING!  Identical." << endl;
      continue;
    }
    else if(chi2 < 0){
      double min1 = h1->GetXaxis()->GetXmin();
      double min2 = h2->GetXaxis()->GetXmin(); 
      double max1 = h1->GetXaxis()->GetXmax();
      double max2 = h2->GetXaxis()->GetXmax();

      double hmin = min1 > min2 ? min2 : min1;
      double hmax = max1 > max2 ? max1 : max2;
      int hnbins = h2->GetNbinsX();

      command1 += Form("_fix(%d,%f,%f)", hnbins, hmin, hmax);
      command2 += Form("_fix(%d,%f,%f)", hnbins, hmin, hmax);
      hist1name += "_fix";
      hist2name += "_fix";
      tree1->Draw(command1.Data());
      tree2->Draw(command2.Data());
      delete h1;
      delete h2;
      h1 = (TH1F*)gDirectory->Get(hist1name.Data());
      h2 = (TH1F*)gDirectory->Get(hist2name.Data());
      c1->Clear();
      h1->Scale(1./h1->GetEntries());
      h2->Scale(1./h2->GetEntries());
    }

    h1->SetTitle(v_commonBranches.at(i));
    h2->SetTitle(v_commonBranches.at(i));

    vector<TH1F*> hvec;
    hvec.push_back(h1);
    vector<string> titles;
    titles.push_back("Old");
    string opts = Form("--isLinear --dataName New --topYaxisTitle New/Old --xAxisOverride --noDivisionLabel --outputName hists/diff%d", i);
    if(!drawWithErrors) opts += " --noErrBars";
    dataMCplotMaker(h2, hvec, titles, "", alias.Data(), opts);
    chi2pair.push_back(make_pair(chi2, i));

    // if(chi2new > 0.999)  myfile << "Branch has somehow got good chi2: " << alias << "   " << chi2new << "\\\\\n";
    
  }//for loop

  // int num =0;
  // for(auto it = chi2pair.begin(); it != chi2pair.end(); ++it)
  //   if(it->first > 0.999) num++;
  // myfile << "\nBefore sorting: " << num << endl << endl;

  std::sort(chi2pair.begin(), chi2pair.end(), comparePair);

  // num =0;
  // for(auto it = chi2pair.begin(); it != chi2pair.end(); ++it)
  //   if(it->first > 0.999) num++;
  // myfile << "\nAfter sorting: " << num << endl << endl;
  
  if(chi2pair.size() == 0) myfile << "There is no branch that found different by a threshold of " << idThreshold << " in between OLD and NEW" << endl;
  for(auto it = chi2pair.begin(); it != chi2pair.end(); ++it){
    myfile << "\\subsection*{" << v_commonBranches.at(it->second) << "}\\addcontentsline{toc}{subsection}{" << v_commonBranches.at(it->second) << "}" << endl
           << "\\begin{figure}[H]" << endl
           << Form("\\includegraphics[width=0.9\\textwidth]{./hists/diff%d.pdf}", it->second) << endl
           << "\\end{figure}" << endl;
    
    if(it->first < 0)
      myfile << "The ranges of the Old and New does not match, cannot get the correct $\\chi^2$ value." << endl;
    else
      myfile << "The $\\chi^2$ test value between the Old and New is: " << it->first << endl;
  }
  myfile << "\\end{document}" << endl;

}
