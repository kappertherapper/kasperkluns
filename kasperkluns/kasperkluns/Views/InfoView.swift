//
//  InfoView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 10/09/2025.
//

import SwiftUI

struct InfoView: View {
    @Environment(ProductService.self) private var productService
    @State private var totalProfit = 0.0
    @State private var totalProfitByMonth = 0.0
    @State private var totalProfitByQuarter = 0.0
    @State private var totalRevenue = 0.0
    @State private var totalProcent = 0.0
    @State private var profitPerProduct = 0.0
    @State private var quarterVAT = 0.0
    
    @State private var totalProfitByMonthCount = 0
    
    @State private var selectedMonth: Month = .january
    @State private var selectedQuarter: Quarter = .Q1
    @State private var selectedYear: Year = .y2025
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    // Revenue
                    VStack(spacing: 12) {
                        Text("Revenue")
                            .font(.title2)
                            .bold()
            
                        Text("\(totalRevenue, specifier: "%.2f") kr")
                            .bold()
                            .italic()
                            .foregroundColor(.gray)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                    
                    // Profit
                    VStack(spacing: 12) {
                        Text("Profit")
                            .font(.title2)
                            .bold()
                        
                        Text("\(totalProfit, specifier: "%.2f") kr")
                            .italic()
                            .bold()
                            .foregroundColor(.gray)
                        
                        Text("\(totalProcent, specifier: "%.2f")%")
                            .bold()
                            .foregroundColor(.green)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Profit Per Product
                HStack {
                    Text("Per-Product Profit:").bold()
                    
                    Text("\(profitPerProduct, specifier: "%.2f") kr")
                        .bold()
                        .foregroundColor(.green)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal)
                
                
                
                // Profit by month
                VStack(spacing: 15) {
                    Text("Profit by Month")
                        .font(.title2)
                        .bold()
                    
                    HStack(spacing: 15) {
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(Month.allCases) { month in
                                Text(month.name).tag(month)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Year", selection: $selectedYear) {
                            ForEach(Year.allCases) { year in
                                Text("\(year.description)").tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("Profit:")
                            .italic()
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(totalProfitByMonth, specifier: "%.2f") kr")
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    //Calculate btn
                    Button {
                        Task {
                                let result = await productService.getTotalProfitAndCountByMonth(
                                    month: selectedMonth.rawValue,
                                    year: selectedYear.rawValue
                                )
                                totalProfitByMonth = result.total
                                totalProfitByMonthCount = result.count
                            }
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Calculate")
                                .bold()
                        }
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                }
                .padding(10)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Revenue by Quarter
                VStack(spacing: 15) {
                    Text("Profit by Quarter")
                        .font(.title2)
                        .bold()
                    
                    Picker("Quarter", selection: $selectedQuarter) {
                        ForEach(Quarter.allCases) { quarter in
                            Text("Q\(quarter.rawValue)").tag(quarter)
                        }
                    }
                    
                    HStack {
                        Text("Profit:")
                            .italic()
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(totalProfitByQuarter, specifier: "%.2f") kr")
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack {
                        Text("VAT:")
                            .italic()
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(quarterVAT, specifier: "%.2f") kr")
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    //Calculate btn
                    Button {
                        Task {
                            totalProfitByQuarter = await productService.getTotalProfitByQuarter(quarter: selectedQuarter.rawValue)
                            quarterVAT = totalProfitByQuarter * 0.20
                        }
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Calculate")
                                .bold()
                        }
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                }
                .padding(10)
                .background(Color.red.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            Task {
                try await productService.fetchProducts()
                totalProfit = await productService.getTotalProfit()
                totalRevenue = await productService.getTotalRevenue()
                profitPerProduct = await productService.getProfitPerProduct()
                totalProcent = totalProfit / totalRevenue * 100
            }
        }
    }
}

#Preview {
    InfoView()
        .environment(ProductService())
}
