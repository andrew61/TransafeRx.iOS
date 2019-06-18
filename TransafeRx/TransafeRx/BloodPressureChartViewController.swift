//
//  BloodPressureChartViewController.swift
//  TransafeRx
//
//  Created by Tachl on 8/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import Charts

class BloodPressureChartViewController: UIViewController{
    
    var xValues = [String]()
    var systolicValues = [Double]()
    var diastolicValues = [Double]()
    var measurements = [BloodPressureMeasurement]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Blood Pressure"

        tableView.dataSource = self
        tableView.alpha = 0.0
        chartView.delegate = self
        chartView.chartDescription?.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let calendar = Calendar(identifier: .gregorian)
        var startDate = Date()
        
        var startDateComp = calendar.dateComponents([.hour, .minute, .year, .month, .day], from: startDate)
        
        startDateComp.hour = 0
        startDateComp.minute = 0
        
        startDate = calendar.date(from: startDateComp)!.subtractDays(daysToSubtract: 30.0)
        
        showProgress()
        ApiManager.sharedManager.getBloodPressureMeasurementChart(model: ChartModel(startDate: startDate, endDate: Date(), aggregate: 1)) { (measurements, error) in
            self.dismissProgress()
            self.systolicValues.removeAll()
            self.diastolicValues.removeAll()
            self.xValues.removeAll()
            for measurement in measurements{
                self.systolicValues.append(Double(measurement.Systolic!))
                self.diastolicValues.append(Double(measurement.Diastolic!))
                self.xValues.append(measurement.ReadingDateUTC!.date)
                self.loadChart(dataPoints: self.xValues, values1: self.systolicValues, values2: self.diastolicValues)
            }
        }
        
        ApiManager.sharedManager.getBloodPressureMeasurements { (measurements, error) in
            self.measurements = measurements
            self.tableView.reloadData()
        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            tableView.alpha = 0.0
            chartView.alpha = 1.0
        }else{
            tableView.alpha = 1.0
            chartView.alpha = 0.0
        }
    }
    
    func loadChart(dataPoints: [String], values1: [Double], values2: [Double]){
        chartView.noDataText = "You need to provide data for the chart."
        
        let xAxis: XAxis = XAxis()
        xAxis.setLabelCount(dataPoints.count, force: true)
        
        let xAxisValueFormatter = LineXAxisValueFormatter(values: xValues)
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count{
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values1[i])
            let dataEntry2 = ChartDataEntry(x: Double(i), y: values2[i])
            
            dataEntries1.append(dataEntry1)
            dataEntries2.append(dataEntry2)
            
            xAxisValueFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = xAxisValueFormatter
        chartView.xAxis.valueFormatter = xAxisValueFormatter
        
        let chartDataSet1 = LineChartDataSet(values: dataEntries1, label: "Systolic")
        chartDataSet1.mode = .linear
        chartDataSet1.axisDependency = .left
        chartDataSet1.setColor(UIColor.blue.withAlphaComponent(0.5))
        chartDataSet1.setCircleColor(UIColor.blue)
        chartDataSet1.valueFont = .systemFont(ofSize: 12.0)

        let chartDataSet2 = LineChartDataSet(values: dataEntries2, label: "Diastolic")
        chartDataSet2.mode = .linear
        chartDataSet2.axisDependency = .left
        chartDataSet2.setColor(UIColor.red.withAlphaComponent(0.5))
        chartDataSet2.setCircleColor(UIColor.red)
        chartDataSet2.valueFont = .systemFont(ofSize: 12.0)

        var chartDataSets : [LineChartDataSet] = [LineChartDataSet]()
        chartDataSets.append(chartDataSet1)
        chartDataSets.append(chartDataSet2)
        
        let chartData = LineChartData(dataSets: chartDataSets)
        
        chartView.setVisibleXRangeMaximum(4.0)
        chartView.legend.enabled = true
        chartView.leftAxis.axisMinimum = 40.0
        chartView.leftAxis.axisMaximum = 250.0
        chartView.rightAxis.axisMinimum = 40.0
        chartView.rightAxis.axisMaximum = 250.0
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.setLabelCount(dataPoints.count, force: true)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .systemFont(ofSize: 8.0)
        chartView.xAxis.labelRotationAngle = 45.0
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        chartView.backgroundColor = UIColor.white
        chartView.data = chartData
        chartView.setVisibleXRangeMaximum(4.0)
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.setVisibleXRangeMaximum(4.0)
    }
}

extension BloodPressureChartViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let measurement = measurements[indexPath.row]
        
        cell.textLabel?.text = measurement.getMeasurement()
        
        return cell
    }
}

extension BloodPressureChartViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}

class LineXAxisValueFormatter: NSObject, IAxisValueFormatter{
    var xValues: [String] = []
    
    init(values: [String]){
        self.xValues = values
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let val = Int(value)
        
        if xValues.count > 0 && val >= 0 && val < xValues.count{
            return xValues[val]
        }else if val == 0{
            return xValues[0]
        }
        return ""
    }
}
