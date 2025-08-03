<template>
  <div class="max-w-[1600px] mx-auto bg-white rounded-lg shadow-lg p-6">
    <!-- 报表头部组件 -->
    <ReportHeader 
      title="上海南华兰陵电气有限公司 - 月度经济运行报表"
      v-model:period="selectedPeriod"
      :is-generating="isGenerating"
      @period-change="loadReportData"
      @generate-pdf="generatePDF"
    />

    <div id="report-content" class="space-y-8">
      <!-- 报表标题和基本信息 -->
      <div class="text-center mb-8">
        <h2 class="text-2xl font-bold mb-2">香港大亚管理办公室 2025</h2>
        <h3 class="text-xl font-semibold mb-2">经济运行统计分析报告</h3>
        <p class="text-lg">上海南华兰陵电气有限公司</p>
        <p class="text-md text-gray-600">{{ formatPeriod(selectedPeriod) }}</p>
      </div>

      <!-- 一、经济运行关键指标进度情况概述 -->
      <div class="mb-8">
        <h3 class="text-xl font-bold mb-4 border-b-2 border-blue-500 pb-2">一、经济运行关键指标进度情况概述（单位：万元）</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <IndicatorCard 
            title="●新签订单："
            :data="keyIndicators.newOrders"
            type="basic"
          />
          <IndicatorCard 
            title="●主营业务收入："
            :data="keyIndicators.mainRevenue"
            type="basic"
          />
          <IndicatorCard 
            title="●净利润指标："
            :data="keyIndicators.netProfit"
            type="basic"
          />
          <IndicatorCard 
            title="●成本中心（计入损益）："
            :data="keyIndicators.costCenter"
            type="cost-center"
          />
        </div>
      </div>

      <!-- 二、经济运行关键指标质量情况概述 -->
      <div class="mb-8">
        <h3 class="text-xl font-bold mb-4 border-b-2 border-blue-500 pb-2">二、经济运行关键指标质量情况概述（金额单位：万元）</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <IndicatorCard 
            title="●边际贡献率指标："
            :data="qualityIndicators.marginContribution"
            type="percentage"
          />
          <IndicatorCard 
            title="●毛利率指标："
            :data="qualityIndicators.grossMargin"
            type="percentage"
          />
          <IndicatorCard 
            title="●净利率指标："
            :data="qualityIndicators.netMargin"
            type="percentage"
          />
          <IndicatorCard 
            title="●净资产收益率指标（年化）："
            :data="qualityIndicators.roe"
            type="percentage"
          />
          <IndicatorCard 
            title="●资产负债率指标："
            :data="qualityIndicators.assetLiabilityRatio"
            type="percentage"
          />
          <IndicatorCard 
            title="●应收账款指标："
            :data="qualityIndicators.receivables"
            type="amount-with-fluctuation"
          />
          <IndicatorCard 
            title="●存量指标："
            :data="qualityIndicators.inventory"
            type="amount-with-fluctuation"
          />
        </div>
      </div>

      <!-- 三、经济运行风险提示 -->
      <div class="mb-8">
        <h3 class="text-xl font-bold mb-4 border-b-2 border-blue-500 pb-2">三、经济运行风险提示</h3>
        <RiskAlert :risks="riskAlertsArray" />
      </div>

      <!-- 四、经济运行关键指标结构分解情况 -->
      <div class="mb-8">
        <h3 class="text-xl font-bold mb-4 border-b-2 border-blue-500 pb-2">四、经济运行关键指标结构分解情况</h3>
        
        <!-- 新签订单结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">1、新签订单结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <SectorTable
            :columns="newOrderColumns"
            :data="newOrderData"
            :show-total="true"
            :total-row="getNewOrderTotal()"
          />
        </div>

        <!-- 项目跟踪情况 -->
        <div class="text-xs text-gray-500 mb-2">
          调试: projectTrackingData = {{ JSON.stringify(projectTrackingData, null, 2) }}
        </div>
        <ProjectTracking :data="projectTrackingData" />

        <!-- 营业收入结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">2、营业收入结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <DataTable 
            :columns="businessIncomeColumns"
            :data="businessIncomeData"
          />
        </div>

        <!-- 存量结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">3、存量结构与质量（按年度计划口径分解，不含合同负债）(单位：万元)</h4>
          <SectorTable
            :columns="inventoryColumns"
            :data="inventoryData"
            :show-total="true"
            :total-row="getInventoryTotal()"
          />
        </div>

        <!-- 主营业务成本结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">4、主营业务成本结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <h5 class="text-md font-medium mb-2">对应年度计划:</h5>
          <SectorTable
            :columns="mainBusinessCostColumns"
            :data="mainBusinessCostData"
            :show-total="true"
            :total-row="getMainBusinessCostTotal()"
          />
        </div>

        <!-- 成本中心结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">5、成本中心结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <h5 class="text-md font-medium mb-2">对应当期收入:</h5>
          <SectorTable
            :columns="costCenterColumns"
            :data="costCenterData"
            :show-total="true"
            :total-row="getCostCenterTotal()"
          />
        </div>

        <!-- 主营业务边际贡献率结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">6、主营业务边际贡献率结构与质量（按年度计划口径分解）</h4>
          <h5 class="text-md font-medium mb-2">对应主营收入:</h5>
          <SectorTable
            :columns="marginContributionColumns"
            :data="marginContributionData"
            :show-total="true"
            :total-row="getMarginContributionTotal()"
          />
        </div>

        <!-- 主营业务毛利率结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">7、主营业务毛利率结构与质量（按年度计划口径分解）</h4>
          <div class="text-sm text-blue-600 mb-2">当期实际值自动计算：(主营收入-主营成本)/主营收入 × 100%</div>
          <SectorTable
            :columns="profitMarginColumns"
            :data="profitMarginData"
            :show-total="true"
            :total-row="getProfitMarginTotal()"
          />
        </div>

        <!-- 净利润结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">8、净利润结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <DataTable
            :columns="netProfitColumns"
            :data="netProfitData"
            :show-total="true"
            :total-row="getNetProfitMainTableTotal()"
          />
        </div>

        <!-- 收款结构与质量 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">9、收款结构与质量（按年度计划口径分解）(单位：万元)</h4>
          <SectorTable
            :columns="receiptColumns"
            :data="receiptData"
            :show-total="true"
            :total-row="getReceiptTotal()"
          />
        </div>

        <!-- 重大投资情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">10、年度重大投资情况（单位：万元）</h4>
          <DataTable
            :columns="majorInvestmentColumns"
            :data="majorInvestmentData"
          />
        </div>

        <!-- 应收账款情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">应收账款情况（单位：万元）</h4>
          <SectorTable
            :columns="accountsReceivableColumns"
            :data="accountsReceivableData"
            :show-total="true"
            :total-row="getAccountsReceivableTotal()"
          />
        </div>

        <!-- 逾期应收账款情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">逾期应收账款情况（单位：万元）</h4>
          <SectorTable
            :columns="overdueReceivablesColumns"
            :data="overdueReceivablesData"
            :show-total="true"
            :total-row="getOverdueReceivablesTotal()"
          />
        </div>

        <!-- 坏账准备情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">坏账准备情况（单位：万元）</h4>
          <SectorTable
            :columns="badDebtProvisionColumns"
            :data="badDebtProvisionData"
            :show-total="true"
            :total-row="getBadDebtProvisionTotal()"
          />
        </div>

        <!-- 产值结构情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">11、产值结构情况（单位：万元）</h4>
          <SectorTable
            :columns="productionValueColumns"
            :data="productionValueData"
            :show-total="true"
            :total-row="getProductionValueTotal()"
          />
        </div>

        <!-- 生产/施工订单生产施工执行情况 -->
        <div class="mb-6">
          <h4 class="text-lg font-semibold mb-3">12、生产/施工订单生产施工执行情况（单位：万元）</h4>
          <SectorTable
            :columns="productionExecutionColumns"
            :data="productionExecutionData"
            :show-total="true"
            :total-row="getProductionExecutionTotal()"
          />
        </div>
      </div>

      <!-- 办公室评估意见 -->
      <div class="mb-8">
        <h3 class="text-xl font-bold mb-4 border-b-2 border-blue-500 pb-2">办公室对{{ formatPeriod(selectedPeriod) }}经济运行情况的整体评估意见：</h3>
        <div class="bg-gray-50 p-4 rounded min-h-[100px]">
          <textarea 
            v-model="officeEvaluation" 
            class="w-full h-24 p-2 border rounded resize-none"
            placeholder="请输入办公室评估意见..."
          ></textarea>
        </div>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="isLoading" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg">
        <div class="flex items-center space-x-3">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
          <span>正在加载数据...</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

// 导入组件
import ReportHeader from '@/components/reports/ReportHeader.vue'
import IndicatorCard from '@/components/reports/IndicatorCard.vue'
import RiskAlert from '@/components/reports/RiskAlert.vue'
import DataTable from '@/components/reports/DataTable.vue'
import SectorTable from '@/components/reports/SectorTable.vue'
import ProjectTracking from '@/components/reports/ProjectTracking.vue'

// 响应式数据
const selectedPeriod = ref(new Date().toISOString().slice(0, 7))
const isLoading = ref(false)
const isGenerating = ref(false)
const officeEvaluation = ref('')

// 关键指标数据
const keyIndicators = ref({
  newOrders: { yearlyPlan: 80000, cumulative: 5559, completionRate: 6.95 },
  mainRevenue: { yearlyPlan: 55000, cumulative: 1999.18, completionRate: 3.33 },
  netProfit: { yearlyPlan: 4000, cumulative: 6.92, completionRate: 0.17 },
  costCenter: { yearlyPlan: 8343.71, cumulative: 499, ratio: 25.60, executionRate: 5.98 }
})

// 质量指标数据
const qualityIndicators = ref({
  marginContribution: { yearlyPlan: 21.98, current: 20.00 },
  grossMargin: { yearlyPlan: 24.00, current: 20.98 },
  netMargin: { yearlyPlan: 6.85, current: 0.01 },
  roe: { yearlyPlan: 21.18, current: 0.04 },
  assetLiabilityRatio: { yearlyPlan: 74.00, current: 78.00 },
  receivables: { initial: 19187.49, current: 23648.98, fluctuation: 23.25 },
  inventory: { initial: 121493.00, current: 126907.00, fluctuation: 4.46 }
})

// 风险提示数据
const riskAlerts = ref({
  financial: '',
  marketing: '当期无风险披露。',
  production: '当期无风险披露。',
  management: '当期无风险披露。',
  research: '当期无风险披露。',
  others: '当期无风险披露。'
})

// 风险提示数组（用于组件）
const riskAlertsArray = computed(() => [
  { type: 'financial', title: '1、财务风险披露情况：', content: riskAlerts.value.financial },
  { type: 'marketing', title: '2、营销风险披露情况：', content: riskAlerts.value.marketing },
  { type: 'production', title: '3、生产/施工风险披露情况：', content: riskAlerts.value.production },
  { type: 'management', title: '4、管理风险披露情况：', content: riskAlerts.value.management },
  { type: 'research', title: '5、研发风险披露情况：', content: riskAlerts.value.research },
  { type: 'others', title: '6、其他风险披露情况：', content: riskAlerts.value.others }
])

// 数据
const newOrderData = ref([])
const businessIncomeData = ref([])
const inventoryData = ref([])
const mainBusinessCostData = ref([])
const costCenterData = ref([])
const marginContributionData = ref([])
const profitMarginData = ref([])
const netProfitData = ref([])
const receiptData = ref([])
const accountsReceivableData = ref([])
const overdueReceivablesData = ref([])
const badDebtProvisionData = ref([])
const productionValueData = ref([])
const productionExecutionData = ref([])
const majorInvestmentData = ref([])
const projectTrackingData = ref({
  equipment: [],
  component: [],
  engineering: []
})

// 表格列配置
const newOrderColumns = [
  { key: 'sector', title: '板块属性' },
  { key: 'customer', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'monthlyRevenue', title: '当月新增', type: 'number', align: 'right' },
  { key: 'cumulativeRevenue', title: '累计新签订单', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'progress', title: '执行进度', type: 'percentage', align: 'right' }
]

const businessIncomeColumns = [
  { key: 'id', title: '序号', align: 'center' },
  { key: 'category', title: '财务科目' },
  { key: 'yearlyPlan', title: '年度计划', type: 'number', align: 'right' },
  { key: 'currentMonthIncome', title: '当月收入', type: 'number', align: 'right' },
  { key: 'accumulatedIncome', title: '累计收入', type: 'number', align: 'right' },
  { key: 'progress', title: '执行进度', type: 'percentage', align: 'right' }
]

const inventoryColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'initialAmount', title: '年初金额', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentAmount', title: '当期金额', type: 'number', align: 'right', cellClass: 'bg-gray-50 font-medium' },
  { key: 'fluctuation', title: '波动率', type: 'percentage', align: 'right' }
]

const netProfitColumns = [
  { key: 'id', title: '序号', align: 'center' },
  { key: 'category', title: '财务科目' },
  { key: 'yearlyPlan', title: '年度计划', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'current', title: '当期', type: 'number', align: 'right' },
  { key: 'cumulative', title: '累计', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'progress', title: '执行进度', type: 'percentage', align: 'right', formatter: (value, row) => calculateNetProfitProgress(row) }
]

const mainBusinessCostColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'executionRate', title: '计划执行率', type: 'percentage', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentMaterialCost', title: '当期直接费用', type: 'number', align: 'right' },
  { key: 'cumulativeMaterialCost', title: '累计直接费用', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentLaborCost', title: '当期制造费用/间接成本', type: 'number', align: 'right' },
  { key: 'cumulativeLaborCost', title: '累计制造费用/间接成本', type: 'number', align: 'right', cellClass: 'bg-gray-50' }
]

const costCenterColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'cumulativeIncome', title: '累计收入', type: 'number', align: 'right', cellClass: 'bg-gray-50 font-medium' },
  { key: 'currentMonthIncome', title: '当期收入', type: 'number', align: 'right' },
  { key: 'percentage', title: '分项占收入比', type: 'percentage', align: 'right' }
]

const marginContributionColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划', type: 'percentage', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentActual', title: '当期实际', type: 'percentage', align: 'right', cellClass: 'font-medium' },
  { key: 'deviation', title: '偏差', type: 'percentage', align: 'right' }
]

const profitMarginColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划', type: 'percentage', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentActual', title: '当期实际', type: 'percentage', align: 'right', cellClass: 'font-medium' },
  { key: 'deviation', title: '偏差', type: 'percentage', align: 'right' }
]

const receiptColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'currentReceipt', title: '当期收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'cumulativeReceipt', title: '累计收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'progress', title: '执行进度', type: 'percentage', align: 'right' }
]

const accountsReceivableColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'initialBalance', title: '年初应收余额', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'newInvoice', title: '当期新增开票', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'totalNewInvoice', title: '累计新增开票', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'currentReceipt', title: '当期收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'totalReceipt', title: '累计收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'currentBalance', title: '当期应收余额', type: 'number', align: 'right', cellClass: 'font-bold' }
]

const overdueReceivablesColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'initialBalance', title: '年初余额', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'newAddition', title: '本年新增', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'monthlyReceipt', title: '当月收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'totalReceipt', title: '累计已收款', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'progress', title: '收款进度', type: 'percentage', align: 'right', cellClass: 'font-bold' }
]

const badDebtProvisionColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customer', title: '客户属性' },
  { key: 'initialBalance', title: '年初余额', type: 'number', align: 'right', cellClass: 'bg-gray-50' },
  { key: 'newAddition', title: '本年新增', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'currentReversal', title: '当月转回', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'accumulatedReversal', title: '累计转回', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'finalBalance', title: '坏账准备余额', type: 'number', align: 'right', cellClass: 'font-bold' }
]

const productionValueColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customerType', title: '客户属性' },
  { key: 'designCapacity', title: '公司设计产能', type: 'number', align: 'right' },
  { key: 'yearlyPlan', title: '年度产能计划', type: 'number', align: 'right' },
  { key: 'currentPeriod', title: '当期产能', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'currentAccumulated', title: '累计产能', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'executionProgress', title: '计划执行进度', type: 'percentage', align: 'right', cellClass: 'font-bold' },
  { key: 'utilizationRate', title: '产能利用率', type: 'percentage', align: 'right', cellClass: 'font-bold' }
]

const productionExecutionColumns = [
  { key: 'sector', title: '板块' },
  { key: 'customerType', title: '客户属性' },
  { key: 'yearlyPlan', title: '年度计划产值', type: 'number', align: 'right' },
  { key: 'selfProduction', title: '自制/自行施工', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'semiProduction', title: '半自制/分包', type: 'number', align: 'right', cellClass: 'font-medium' },
  { key: 'outsourcing', title: '外发/转包', type: 'number', align: 'right', cellClass: 'font-medium' }
]

const majorInvestmentColumns = [
  { key: 'id', title: '序号', align: 'center' },
  { key: 'projectName', title: '项目名称' },
  { key: 'initialPlan', title: '年初计划', type: 'number', align: 'right' },
  { key: 'currentExecution', title: '当期执行', type: 'number', align: 'right' },
  { key: 'progress', title: '执行进度', type: 'percentage', align: 'right' }
]

// 工具函数
const formatNumber = (num) => {
  if (num === null || num === undefined) return '0.00'
  return Number(num).toFixed(2)
}

const formatPeriod = (period) => {
  if (!period) return ''
  const [year, month] = period.split('-')
  return `${year} 年 ${month.padStart(2, '0')} 月`
}

// 计算函数
const getNewOrderTotal = () => {
  const total = {
    yearlyPlan: 0,
    monthlyRevenue: 0,
    cumulativeRevenue: 0,
    progress: 0
  }

  newOrderData.value.forEach(item => {
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.monthlyRevenue += Number(item.monthlyRevenue) || 0
    total.cumulativeRevenue += Number(item.cumulativeRevenue) || 0
  })

  total.progress = total.yearlyPlan > 0 ? (total.cumulativeRevenue / total.yearlyPlan * 100).toFixed(2) : '0.00'
  return total
}

const getInventoryTotal = () => {
  const total = {
    initialAmount: 0,
    currentAmount: 0,
    fluctuation: '0.00'
  }

  inventoryData.value.forEach(item => {
    total.initialAmount += Number(item.initialAmount) || 0
    total.currentAmount += Number(item.currentAmount) || 0
  })

  if (total.initialAmount === 0) {
    total.fluctuation = total.currentAmount === 0 ? '0.00' : '0.00'
  } else {
    const fluctuation = ((total.currentAmount - total.initialAmount) / total.initialAmount) * 100
    total.fluctuation = fluctuation.toFixed(2)
  }

  return total
}

const calculateNetProfitProgress = (item) => {
  const yearlyPlan = Number(item.yearlyPlan) || 0
  const cumulative = Number(item.cumulative) || 0
  if (yearlyPlan === 0) return '0.00'
  return ((cumulative / yearlyPlan) * 100).toFixed(2)
}

const getNetProfitMainTableTotal = () => {
  const total = {
    yearlyPlan: 0,
    current: 0,
    cumulative: 0,
    progress: 0
  }

  netProfitData.value.forEach(item => {
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.current += Number(item.current) || 0
    total.cumulative += Number(item.cumulative) || 0
  })

  total.progress = total.yearlyPlan > 0 ? ((total.cumulative / total.yearlyPlan) * 100).toFixed(2) : '0.00'
  return total
}

const getMainBusinessCostTotal = () => {
  const total = {
    yearlyPlan: 0,
    executionRate: '0.00',
    currentMaterialCost: 0,
    cumulativeMaterialCost: 0,
    currentLaborCost: 0,
    cumulativeLaborCost: 0
  }

  mainBusinessCostData.value.forEach(item => {
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.currentMaterialCost += Number(item.currentMaterialCost) || 0
    total.cumulativeMaterialCost += Number(item.cumulativeMaterialCost) || 0
    total.currentLaborCost += Number(item.currentLaborCost) || 0
    total.cumulativeLaborCost += Number(item.cumulativeLaborCost) || 0
  })

  total.executionRate = total.yearlyPlan > 0 ? ((total.cumulativeMaterialCost / total.yearlyPlan) * 100).toFixed(2) : '0.00'
  return total
}

const getCostCenterTotal = () => {
  const total = {
    cumulativeIncome: 0,
    currentMonthIncome: 0,
    percentage: '100.00'
  }

  costCenterData.value.forEach(item => {
    total.cumulativeIncome += Number(item.cumulativeIncome) || 0
    total.currentMonthIncome += Number(item.currentMonthIncome) || 0
  })

  return total
}

const getMarginContributionTotal = () => {
  const total = {
    yearlyPlan: '0.00',
    currentActual: '0.00',
    deviation: '0.00'
  }

  if (marginContributionData.value.length > 0) {
    const totalYearlyPlan = marginContributionData.value.reduce((sum, item) => sum + (Number(item.yearlyPlan) || 0), 0)
    const totalCurrentActual = marginContributionData.value.reduce((sum, item) => sum + (Number(item.currentActual) || 0), 0)

    total.yearlyPlan = (totalYearlyPlan / marginContributionData.value.length).toFixed(2)
    total.currentActual = (totalCurrentActual / marginContributionData.value.length).toFixed(2)
    total.deviation = (Number(total.currentActual) - Number(total.yearlyPlan)).toFixed(2)
  }

  return total
}

const getProfitMarginTotal = () => {
  const total = {
    yearlyPlan: '0.00',
    currentActual: '0.00',
    deviation: '0.00'
  }

  if (profitMarginData.value.length > 0) {
    const totalYearlyPlan = profitMarginData.value.reduce((sum, item) => sum + (Number(item.yearlyPlan) || 0), 0)
    const totalCurrentActual = profitMarginData.value.reduce((sum, item) => sum + (Number(item.currentActual) || 0), 0)

    total.yearlyPlan = (totalYearlyPlan / profitMarginData.value.length).toFixed(2)
    total.currentActual = (totalCurrentActual / profitMarginData.value.length).toFixed(2)
    total.deviation = (Number(total.currentActual) - Number(total.yearlyPlan)).toFixed(2)
  }

  return total
}

const getReceiptTotal = () => {
  const total = {
    yearlyPlan: 0,
    currentReceipt: 0,
    cumulativeReceipt: 0,
    progress: '0.00'
  }

  receiptData.value.forEach(item => {
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.currentReceipt += Number(item.currentReceipt) || 0
    total.cumulativeReceipt += Number(item.cumulativeReceipt) || 0
  })

  total.progress = total.yearlyPlan > 0 ? ((total.cumulativeReceipt / total.yearlyPlan) * 100).toFixed(2) : '0.00'
  return total
}

const getAccountsReceivableTotal = () => {
  const total = {
    initialBalance: 0,
    newInvoice: 0,
    totalNewInvoice: 0,
    currentReceipt: 0,
    totalReceipt: 0,
    currentBalance: 0
  }

  accountsReceivableData.value.forEach(item => {
    total.initialBalance += Number(item.initialBalance) || 0
    total.newInvoice += Number(item.newInvoice) || 0
    total.totalNewInvoice += Number(item.totalNewInvoice) || 0
    total.currentReceipt += Number(item.currentReceipt) || 0
    total.totalReceipt += Number(item.totalReceipt) || 0
    total.currentBalance += Number(item.currentBalance) || 0
  })

  return total
}

const getOverdueReceivablesTotal = () => {
  const total = {
    initialBalance: 0,
    newAddition: 0,
    monthlyReceipt: 0,
    totalReceipt: 0,
    progress: '0.00'
  }

  overdueReceivablesData.value.forEach(item => {
    total.initialBalance += Number(item.initialBalance) || 0
    total.newAddition += Number(item.newAddition) || 0
    total.monthlyReceipt += Number(item.monthlyReceipt) || 0
    total.totalReceipt += Number(item.totalReceipt) || 0
  })

  const totalAmount = total.initialBalance + total.newAddition
  total.progress = totalAmount > 0 ? ((total.totalReceipt / totalAmount) * 100).toFixed(2) : '0.00'
  return total
}

const getBadDebtProvisionTotal = () => {
  const total = {
    initialBalance: 0,
    newAddition: 0,
    currentReversal: 0,
    accumulatedReversal: 0,
    finalBalance: 0
  }

  badDebtProvisionData.value.forEach(item => {
    total.initialBalance += Number(item.initialBalance) || 0
    total.newAddition += Number(item.newAddition) || 0
    total.currentReversal += Number(item.currentReversal) || 0
    total.accumulatedReversal += Number(item.accumulatedReversal) || 0
    total.finalBalance += Number(item.finalBalance) || 0
  })

  return total
}

const getProductionValueTotal = () => {
  const total = {
    designCapacity: 0,
    yearlyPlan: 0,
    currentPeriod: 0,
    currentAccumulated: 0,
    executionProgress: '0.00',
    utilizationRate: '0.00'
  }

  productionValueData.value.forEach(item => {
    total.designCapacity += Number(item.designCapacity) || 0
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.currentPeriod += Number(item.currentPeriod) || 0
    total.currentAccumulated += Number(item.currentAccumulated) || 0
  })

  total.executionProgress = total.yearlyPlan > 0 ? ((total.currentAccumulated / total.yearlyPlan) * 100).toFixed(2) : '0.00'
  total.utilizationRate = total.designCapacity > 0 ? ((total.currentAccumulated / total.designCapacity) * 100).toFixed(2) : '0.00'
  return total
}

const getProductionExecutionTotal = () => {
  const total = {
    yearlyPlan: 0,
    selfProduction: 0,
    semiProduction: 0,
    outsourcing: 0
  }

  productionExecutionData.value.forEach(item => {
    total.yearlyPlan += Number(item.yearlyPlan) || 0
    total.selfProduction += Number(item.selfProduction) || 0
    total.semiProduction += Number(item.semiProduction) || 0
    total.outsourcing += Number(item.outsourcing) || 0
  })

  return total
}

// 数据加载
const loadReportData = async () => {
  isLoading.value = true
  try {
    // 模拟数据加载
    await loadMockData()
  } catch (error) {
    console.error('加载报表数据失败:', error)
  } finally {
    isLoading.value = false
  }
}

const loadMockData = async () => {
  // 新签订单数据
  newOrderData.value = [
    { id: 'equipment-上海项目', sector: '设备', customer: '上海项目', yearlyPlan: 30000.00, monthlyRevenue: 1459.37, cumulativeRevenue: 1459.37, progress: '4.86' },
    { id: 'equipment-国网项目', sector: '设备', customer: '国网项目', yearlyPlan: 8000.00, monthlyRevenue: 0, cumulativeRevenue: 0, progress: '0.00' },
    { id: 'components-用户项目', sector: '元件', customer: '用户项目', yearlyPlan: 4000.00, monthlyRevenue: 0, cumulativeRevenue: 0, progress: '0.00' },
    { id: 'engineering-一包项目', sector: '工程', customer: '一包项目', yearlyPlan: 3900.00, monthlyRevenue: 0, cumulativeRevenue: 0, progress: '0.00' }
  ]

  // 营业收入数据
  businessIncomeData.value = [
    { id: 1, category: '主营业务', yearlyPlan: 55000, currentMonthIncome: 1949.57, accumulatedIncome: 1949.57, progress: 3.28 },
    { id: 2, category: '非主营业务', yearlyPlan: 600, currentMonthIncome: 49.61, accumulatedIncome: 49.61, progress: 8.27 }
  ]

  // 存量数据
  inventoryData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', initialAmount: 39151.53, currentAmount: 0, fluctuation: '0.00' },
    { id: 'component-用户', sector: '元件', customer: '用户', initialAmount: 26.60, currentAmount: 0, fluctuation: '0.00' },
    { id: 'project-一包', sector: '工程', customer: '一包', initialAmount: 12720.17, currentAmount: 0, fluctuation: '0.00' }
  ]

  // 主营业务成本数据
  mainBusinessCostData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', yearlyPlan: 25000, executionRate: '5.84', currentMaterialCost: 1200, cumulativeMaterialCost: 1460, currentLaborCost: 300, cumulativeLaborCost: 380 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', yearlyPlan: 6000, executionRate: '0.00', currentMaterialCost: 0, cumulativeMaterialCost: 0, currentLaborCost: 0, cumulativeLaborCost: 0 },
    { id: 'component-用户', sector: '元件', customer: '用户', yearlyPlan: 3000, executionRate: '0.00', currentMaterialCost: 0, cumulativeMaterialCost: 0, currentLaborCost: 0, cumulativeLaborCost: 0 },
    { id: 'project-一包', sector: '工程', customer: '一包', yearlyPlan: 2900, executionRate: '0.00', currentMaterialCost: 0, cumulativeMaterialCost: 0, currentLaborCost: 0, cumulativeLaborCost: 0 }
  ]

  // 成本中心数据
  costCenterData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', cumulativeIncome: 1949.57, currentMonthIncome: 1949.57, percentage: '97.52' },
    { id: 'equipment-国网', sector: '设备', customer: '国网', cumulativeIncome: 0, currentMonthIncome: 0, percentage: '0.00' },
    { id: 'component-用户', sector: '元件', customer: '用户', cumulativeIncome: 0, currentMonthIncome: 0, percentage: '0.00' },
    { id: 'project-一包', sector: '工程', customer: '一包', cumulativeIncome: 0, currentMonthIncome: 0, percentage: '0.00' },
    { id: 'non-main-business', sector: '非主营业务', customer: '', cumulativeIncome: 49.61, currentMonthIncome: 49.61, percentage: '2.48' }
  ]

  // 边际贡献率数据
  marginContributionData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', yearlyPlan: 22.50, currentActual: 20.00, deviation: -2.50 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', yearlyPlan: 25.00, currentActual: 0.00, deviation: -25.00 },
    { id: 'component-用户', sector: '元件', customer: '用户', yearlyPlan: 18.00, currentActual: 0.00, deviation: -18.00 },
    { id: 'project-一包', sector: '工程', customer: '一包', yearlyPlan: 20.00, currentActual: 0.00, deviation: -20.00 }
  ]

  // 毛利率数据
  profitMarginData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', yearlyPlan: 25.00, currentActual: 20.98, deviation: -4.02 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', yearlyPlan: 28.00, currentActual: 0.00, deviation: -28.00 },
    { id: 'component-用户', sector: '元件', customer: '用户', yearlyPlan: 20.00, currentActual: 0.00, deviation: -20.00 },
    { id: 'project-一包', sector: '工程', customer: '一包', yearlyPlan: 22.00, currentActual: 0.00, deviation: -22.00 }
  ]

  // 净利润数据
  netProfitData.value = [
    { id: 1, category: '主营业务', yearlyPlan: 3871.58, current: 0.00, cumulative: 1479.37, progress: 38.21 },
    { id: 2, category: '非主营业务', yearlyPlan: 128.42, current: 0.00, cumulative: 224.15, progress: 174.58 }
  ]

  // 收款数据
  receiptData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', yearlyPlan: 30000, currentReceipt: 1500, cumulativeReceipt: 1500, progress: 5.00 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', yearlyPlan: 8000, currentReceipt: 0, cumulativeReceipt: 0, progress: 0.00 },
    { id: 'component-用户', sector: '元件', customer: '用户', yearlyPlan: 4000, currentReceipt: 0, cumulativeReceipt: 0, progress: 0.00 },
    { id: 'project-一包', sector: '工程', customer: '一包', yearlyPlan: 3900, currentReceipt: 0, cumulativeReceipt: 0, progress: 0.00 }
  ]

  // 应收账款数据
  accountsReceivableData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', initialBalance: 15000, newInvoice: 1200, totalNewInvoice: 1200, currentReceipt: 1500, totalReceipt: 1500, currentBalance: 14700 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', initialBalance: 3000, newInvoice: 0, totalNewInvoice: 0, currentReceipt: 0, totalReceipt: 0, currentBalance: 3000 },
    { id: 'component-用户', sector: '元件', customer: '用户', initialBalance: 800, newInvoice: 0, totalNewInvoice: 0, currentReceipt: 0, totalReceipt: 0, currentBalance: 800 },
    { id: 'project-一包', sector: '工程', customer: '一包', initialBalance: 387.49, newInvoice: 0, totalNewInvoice: 0, currentReceipt: 0, totalReceipt: 0, currentBalance: 387.49 }
  ]

  // 逾期应收账款数据
  overdueReceivablesData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', initialBalance: 5000, newAddition: 200, monthlyReceipt: 300, totalReceipt: 300, progress: 5.77 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', initialBalance: 1500, newAddition: 0, monthlyReceipt: 0, totalReceipt: 0, progress: 0.00 },
    { id: 'component-用户', sector: '元件', customer: '用户', initialBalance: 400, newAddition: 0, monthlyReceipt: 0, totalReceipt: 0, progress: 0.00 },
    { id: 'project-一包', sector: '工程', customer: '一包', initialBalance: 200, newAddition: 0, monthlyReceipt: 0, totalReceipt: 0, progress: 0.00 }
  ]

  // 坏账准备数据
  badDebtProvisionData.value = [
    { id: 'equipment-上海', sector: '设备', customer: '上海', initialBalance: 750, newAddition: 10, currentReversal: 0, accumulatedReversal: 0, finalBalance: 760 },
    { id: 'equipment-国网', sector: '设备', customer: '国网', initialBalance: 150, newAddition: 0, currentReversal: 0, accumulatedReversal: 0, finalBalance: 150 },
    { id: 'component-用户', sector: '元件', customer: '用户', initialBalance: 40, newAddition: 0, currentReversal: 0, accumulatedReversal: 0, finalBalance: 40 },
    { id: 'project-一包', sector: '工程', customer: '一包', initialBalance: 19.37, newAddition: 0, currentReversal: 0, accumulatedReversal: 0, finalBalance: 19.37 }
  ]

  // 产值结构数据
  productionValueData.value = [
    { id: 'equipment-上海', sector: '设备', customerType: '上海', designCapacity: 50000, yearlyPlan: 30000, currentPeriod: 1459, currentAccumulated: 1459, executionProgress: 4.86, utilizationRate: 2.92 },
    { id: 'equipment-国网', sector: '设备', customerType: '国网', designCapacity: 20000, yearlyPlan: 8000, currentPeriod: 0, currentAccumulated: 0, executionProgress: 0.00, utilizationRate: 0.00 },
    { id: 'component-用户', sector: '元件', customerType: '用户', designCapacity: 8000, yearlyPlan: 4000, currentPeriod: 0, currentAccumulated: 0, executionProgress: 0.00, utilizationRate: 0.00 },
    { id: 'project-一包', sector: '工程', customerType: '一包', designCapacity: 6000, yearlyPlan: 3900, currentPeriod: 0, currentAccumulated: 0, executionProgress: 0.00, utilizationRate: 0.00 }
  ]

  // 生产执行数据
  productionExecutionData.value = [
    { id: 'equipment-上海', sector: '设备', customerType: '上海', yearlyPlan: 30000, selfProduction: 1200, semiProduction: 200, outsourcing: 59 },
    { id: 'equipment-国网', sector: '设备', customerType: '国网', yearlyPlan: 8000, selfProduction: 0, semiProduction: 0, outsourcing: 0 },
    { id: 'component-用户', sector: '元件', customerType: '用户', yearlyPlan: 4000, selfProduction: 0, semiProduction: 0, outsourcing: 0 },
    { id: 'project-一包', sector: '工程', customerType: '一包', yearlyPlan: 3900, selfProduction: 0, semiProduction: 0, outsourcing: 0 }
  ]

  // 重大投资数据
  majorInvestmentData.value = [
    { id: 1, projectName: '生产设备升级改造项目', initialPlan: 1000, currentExecution: 0, progress: 0.00 },
    { id: 2, projectName: '信息化系统建设项目', initialPlan: 500, currentExecution: 0, progress: 0.00 },
    { id: 3, projectName: '研发中心扩建项目', initialPlan: 800, currentExecution: 0, progress: 0.00 }
  ]

  // 项目跟踪数据
  projectTrackingData.value = {
    equipment: [
      { customerType: '上海', yearlyPlan: 500000.00, currentPeriod: 1459.37, currentTotal: 1459.37 },
      { customerType: '国网', yearlyPlan: 1050000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '江苏', yearlyPlan: 300000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '输配电内配', yearlyPlan: 0.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '西门子', yearlyPlan: 0.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '同业', yearlyPlan: 0.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '用户', yearlyPlan: 20000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '其它', yearlyPlan: 0.00, currentPeriod: 0, currentTotal: 0 }
    ],
    component: [
      { customerType: '用户', yearlyPlan: 0.00, currentPeriod: 0, currentTotal: 0 }
    ],
    engineering: [
      { customerType: '一包', yearlyPlan: 150000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '二包', yearlyPlan: 600.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '域内合作', yearlyPlan: 95000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '域外合作', yearlyPlan: 5000.00, currentPeriod: 0, currentTotal: 0 },
      { customerType: '其它', yearlyPlan: 2000.00, currentPeriod: 3031.54, currentTotal: 3031.54 }
    ]
  }
}

// PDF生成
const generatePDF = async () => {
  isGenerating.value = true
  try {
    const element = document.getElementById('report-content')
    
    const canvas = await html2canvas(element, {
      scale: 2,
      useCORS: true,
      allowTaint: true,
      backgroundColor: '#ffffff'
    })
    
    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF('p', 'mm', 'a4')
    const imgWidth = 210
    const pageHeight = 295
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    let heightLeft = imgHeight
    
    let position = 0
    
    pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
    heightLeft -= pageHeight
    
    while (heightLeft >= 0) {
      position = heightLeft - imgHeight
      pdf.addPage()
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      heightLeft -= pageHeight
    }
    
    const fileName = `上海南华兰陵电气有限公司_月度经济运行报表_${selectedPeriod.value}.pdf`
    pdf.save(fileName)
    
  } catch (error) {
    console.error('生成PDF失败:', error)
    alert('生成PDF失败，请重试')
  } finally {
    isGenerating.value = false
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadReportData()
})
</script>

<style scoped>
@media print {
  .no-print {
    display: none !important;
  }
}

.table-container {
  page-break-inside: avoid;
}

h3, h4 {
  page-break-after: avoid;
}
</style>
