//
//  LigandsViewController.swift
//  Swifty Proteins
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/26.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class LigandsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchArr: [String] = [];
    var isSearching = false;
    var selectedRow: String = "";
    @IBOutlet weak var ligandsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArr = Data.ligands.filter({$0.lowercased().contains(searchText.lowercased())});
        if searchText == ""{
            isSearching = false;
        }
        else{
            isSearching = true;
        }
        ligandsTable.reloadData();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
        ligandsTable.reloadData();
        searchBar.text = "";
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching{
            selectedRow = searchArr[indexPath.row];
        }
        else{
            selectedRow = Data.ligands[indexPath.row];
        }
        performSegue(withIdentifier: "toProteinSegue", sender: self);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return searchArr.count;
        }else{
            return Data.ligands.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandsCell") as! LigandTableViewCell;
        
        if isSearching{
            cell.name = searchArr[indexPath.row];
        }else{
            cell.name = Data.ligands[indexPath.row];
        }
        
        return cell;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLigands(fileName: "ligands");
    }
    
    func getLigands(fileName: String){
        if let filepath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                Data.ligands = contents.components(separatedBy: "\n");
                var indexPaths: [IndexPath] = [];
                for c in 0..<Data.ligands.count{
                    indexPaths.append(IndexPath(row: c, section: 0));
                }
                self.ligandsTable.beginUpdates();
                self.ligandsTable.insertRows(at: indexPaths, with: .automatic);
                self.ligandsTable.endUpdates();
            } catch (let e) {
                print(e)
            }
        } else {
            print("Something went wrong.");
        }
    }
    
    @IBAction func LigardsUnWindSegue(segue: UIStoryboardSegue){
        if segue.identifier == "backToLigands"{
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backFromLigands"{
            
        }
        else if segue.identifier == "toProteinSegue"{
            segue.destination.title = selectedRow;
        }
    }
}
