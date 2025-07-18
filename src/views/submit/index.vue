<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <div class="max-w-7xl mx-auto">
      <!-- 页面标题 -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">提交表单</h1>
        <p class="text-gray-600 mt-2">选择需要填写的表单模块</p>
      </div>

      <!-- 期间选择 -->
      <div class="bg-white p-6 rounded-lg shadow-sm mb-6">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- 期间选择 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">选择期间</label>
            <input 
              v-model="selectedPeriod"
              type="month"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <!-- 分类选择 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">选择分类</label>
            <select 
              v-model="selectedCategory" 
              @change="onCategoryChange"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">请选择分类</option>
              <option v-for="category in availableCategories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>

          <!-- 表单选择 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">选择表单</label>
            <select 
              v-model="selectedModule" 
              @change="onModuleChange"
              :disabled="!selectedCategory"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
            >
              <option value="">请选择表单</option>
              <option 
                v-for="module in filteredModules" 
                :key="module.id" 
                :value="module"
              >
                {{ module.module_name }}
                <span v-if="getSubmissionStatus(module)" class="text-green-600">(已提交)</span>
              </option>
            </select>
          </div>
        </div>

        <!-- 提交按钮 -->
        <div class="mt-6 flex items-center space-x-4">
          <button 
            @click="navigateToModule"
            :disabled="!selectedModule"
            class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            {{ getSubmissionStatus(selectedModule) ? '编辑表单' : '填写表单' }}
          </button>
          
          <div v-if="selectedModule" class="text-sm text-gray-600">
            <div v-if="getSubmissionStatus(selectedModule)" class="text-green-600">
              <div>✓ 当前期间已提交</div>
              <div v-if="getSubmissionInfo(selectedModule)" class="text-xs mt-1">
                最后提交人: {{ getSubmissionInfo(selectedModule)?.last_submitted_by || '系统' }}
                ({{ getSubmissionInfo(selectedModule)?.submission_count || 1 }}次提交)
              </div>
            </div>
            <span v-else class="text-orange-600">
              ⚠ 当前期间未提交
            </span>
          </div>
        </div>
      </div>

      <!-- 快速提交区域 -->
      <div class="bg-white rounded-lg shadow-sm mb-6">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">本月待提交表单</h3>
          <p class="text-sm text-gray-600 mt-1">当前期间: {{ selectedPeriod }}</p>
        </div>
        
        <div class="p-6">
          <div v-if="loading" class="text-center py-8 text-gray-500">
            <div class="animate-spin w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full mx-auto mb-4"></div>
            加载中...
          </div>
          
          <div v-else-if="pendingForms.length === 0" class="text-center py-8 text-gray-500">
            <svg class="w-12 h-12 mx-auto mb-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <p>恭喜！当前期间所有表单都已提交</p>
          </div>
          
          <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div 
              v-for="form in pendingForms" 
              :key="form.id"
              class="p-4 border border-red-200 bg-red-50 rounded-lg hover:border-red-300 hover:shadow-sm transition-all cursor-pointer"
              @click="navigateToModuleDirectly(form)"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1">
                  <h5 class="font-medium text-gray-900 text-sm">{{ form.module_name }}</h5>
                  <p class="text-xs text-gray-600 mt-1">{{ form.module_category }}</p>
                  <p class="text-xs text-red-600 mt-2">待提交</p>
                </div>
                <button 
                  @click.stop="navigateToModuleDirectly(form)"
                  class="px-3 py-1 bg-red-600 text-white text-xs rounded-md hover:bg-red-700 transition-colors"
                >
                  填写
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 可填写表单列表 -->
      <div class="bg-white rounded-lg shadow-sm">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">可填写的表单列表</h3>
        </div>
        
        <div class="p-6">
          <div v-if="categorizedWritableModules.length === 0" class="text-center py-8 text-gray-500">
            暂无可填写的表单
          </div>
          
          <div v-else class="space-y-6">
            <div v-for="category in categorizedWritableModules" :key="category.name" class="border rounded-lg p-4">
              <h4 class="text-md font-semibold text-gray-800 mb-3 flex items-center">
                <span class="w-3 h-3 rounded-full mr-2" 
                      :class="{
                        'bg-blue-500': category.name === '财务',
                        'bg-green-500': category.name === '营销', 
                        'bg-yellow-500': category.name === '生产',
                        'bg-purple-500': category.name === '企管'
                      }"></span>
                {{ category.name }} ({{ category.modules.length }} 个模块)
              </h4>
              
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                <div 
                  v-for="module in category.modules" 
                  :key="module.id"
                  class="p-3 border rounded-lg hover:border-blue-300 hover:shadow-sm transition-all cursor-pointer"
                  :class="{
                    'border-gray-200': !getSubmissionStatus(module),
                    'border-green-200 bg-green-50': getSubmissionStatus(module)
                  }"
                  @click="navigateToModuleDirectly(module)"
                >
                  <div class="flex items-center justify-between">
                    <div class="flex-1">
                      <h5 class="font-medium text-gray-900 text-sm">{{ module.module_name }}</h5>
                      <p class="text-xs text-gray-600 mt-1">{{ module.description }}</p>
                      <div class="mt-2 flex flex-col text-xs space-y-1">
                        <span v-if="getSubmissionStatus(module)" class="text-green-600">
                          ✓ {{ selectedPeriod }} 已提交
                        </span>
                        <span v-else class="text-orange-600">
                          ⚠ {{ selectedPeriod }} 未提交
                        </span>
                        <span v-if="getSubmissionInfo(module)" class="text-gray-500">
                          最后提交: {{ getSubmissionInfo(module)?.last_submitted_by || '系统' }}
                        </span>
                      </div>
                    </div>
                    <div class="ml-3">
                      <button 
                        @click.stop="navigateToModuleDirectly(module)"
                        class="px-2 py-1 text-xs rounded-md transition-colors"
                        :class="{
                          'bg-blue-600 text-white hover:bg-blue-700': !getSubmissionStatus(module),
                          'bg-green-600 text-white hover:bg-green-700': getSubmissionStatus(module)
                        }"
                      >
                        {{ getSubmissionStatus(module) ? '编辑' : '填写' }}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

interface Module {
  id: number
  module_name: string
  module_key: string
  module_category: string
  route_path: string
  description: string
  permission_type: 'read' | 'write'
}

interface CategorizedModule {
  name: string
  modules: Module[]
}

interface SubmissionRecord {
  module_id: number
  period: string
  submitted_at: string
  last_submitted_by?: string
  submission_count?: number
}

const router = useRouter()
const userStore = useUserStore()

const modules = ref<Module[]>([])
const submissions = ref<SubmissionRecord[]>([])
const pendingForms = ref<Module[]>([])
const loading = ref(true)
// 默认选择上个月（当前月份-1）
const selectedPeriod = ref((() => {
  const now = new Date()
  now.setMonth(now.getMonth() - 1)
  return now.toISOString().slice(0, 7)
})()) // YYYY-MM
const selectedCategory = ref('')
const selectedModule = ref<Module | null>(null)

// 计算可写模块
const writableModules = computed(() => {
  return modules.value.filter(m => m.permission_type === 'write')
})

// 计算可用分类
const availableCategories = computed(() => {
  const categories = [...new Set(writableModules.value.map(m => m.module_category))]
  return categories.sort()
})

// 计算过滤后的模块
const filteredModules = computed(() => {
  if (!selectedCategory.value) return []
  return writableModules.value.filter(m => m.module_category === selectedCategory.value)
})

// 计算分类可写模块
const categorizedWritableModules = computed(() => {
  const categoryMap = new Map<string, Module[]>()
  
  writableModules.value.forEach(module => {
    if (!categoryMap.has(module.module_category)) {
      categoryMap.set(module.module_category, [])
    }
    categoryMap.get(module.module_category)!.push(module)
  })
  
  const result: CategorizedModule[] = []
  categoryMap.forEach((moduleList, categoryName) => {
    result.push({
      name: categoryName,
      modules: moduleList.sort((a, b) => a.module_name.localeCompare(b.module_name))
    })
  })
  
  return result.sort((a, b) => a.name.localeCompare(b.name))
})

// 获取表单提交状态
const getSubmissionStatus = (module: Module | null) => {
  if (!module) return false
  return submissions.value.some(s => s.module_id === module.id && s.period === selectedPeriod.value)
}

// 获取表单提交详细信息
const getSubmissionInfo = (module: Module | null) => {
  if (!module) return null
  return submissions.value.find(s => s.module_id === module.id && s.period === selectedPeriod.value)
}

// 获取用户可访问的模块
const fetchUserModules = async () => {
  try {
    const userId = userStore.userInfo?.id || 1
    const response = await fetch(`http://47.111.95.19:3000/permissions/user/${userId}`)
    
    if (!response.ok) {
      throw new Error('获取用户权限失败')
    }
    
    const result = await response.json()
    if (result.success) {
      modules.value = result.data.accessible_modules || []
    }
  } catch (error) {
    console.error('获取用户模块失败:', error)
  }
}

// 获取提交记录 (系统级别，包含详细信息)
const fetchSubmissions = async () => {
  try {
    const userId = userStore.userInfo?.id || 1
    // 获取用户可访问的模块的提交状态
    const response = await fetch(`http://47.111.95.19:3000/forms/status/${selectedPeriod.value}?userId=${userId}`)
    
    if (!response.ok) {
      throw new Error('获取提交记录失败')
    }
    
    const result = await response.json()
    if (result.success && result.data?.modules) {
      // 转换为 SubmissionRecord 格式，只包含已提交的
      submissions.value = result.data.modules
        .filter((module: any) => module.submission_status?.status === 'submitted')
        .map((module: any) => ({
          module_id: module.module_id,
          period: selectedPeriod.value,
          submitted_at: module.submission_status.submitted_at,
          last_submitted_by: module.submission_status.last_submitted_by,
          submission_count: module.submission_status.submission_count
        }))
    }
  } catch (error) {
    console.error('获取提交记录失败:', error)
    // 如果新API失败，回退到简单的方式
    try {
      const fallbackResponse = await fetch(`http://47.111.95.19:3000/permissions/user/${userStore.userInfo?.id || 1}/submissions?period=${selectedPeriod.value}`)
      if (fallbackResponse.ok) {
        const fallbackResult = await fallbackResponse.json()
        if (fallbackResult.success) {
          submissions.value = fallbackResult.data || []
        }
      }
    } catch (fallbackError) {
      console.error('回退API也失败:', fallbackError)
    }
  }
}

// 获取待提交表单
const fetchPendingForms = async () => {
  try {
    const userId = userStore.userInfo?.id || 1
    const response = await fetch(`http://47.111.95.19:3000/permissions/user/${userId}/pending-forms?period=${selectedPeriod.value}`)
    
    if (!response.ok) {
      throw new Error('获取待提交表单失败')
    }
    
    const result = await response.json()
    if (result.success) {
      pendingForms.value = result.data || []
    }
  } catch (error) {
    console.error('获取待提交表单失败:', error)
  }
}

// 分类变化处理
const onCategoryChange = () => {
  selectedModule.value = null
}

// 模块变化处理
const onModuleChange = () => {
  // 可以在这里添加额外的逻辑
}

// 导航到选中的模块
const navigateToModule = () => {
  if (selectedModule.value) {
    navigateToModuleDirectly(selectedModule.value)
  }
}

// 直接导航到模块
const navigateToModuleDirectly = (module: Module) => {
  // 路径修正映射 - 将错误的路径映射到正确的路径
  const pathCorrections: { [key: string]: string } = {
    '/example/CostCenterStructure': '/cost-center-structure',
    '/example/BalanceSheet': '/example',
    '/example/CashFlowStatement': '/cashflow',
    '/example/IncomeStatement': '/incomestatement',
    '/example/ProductionValue': '/production-value',
    '/example/ProjectTracking': '/projecttracking',
    // 企管模块路径修正
    '/Users/yaowenya/Desktop/大亚发展集团/financial-analytics-platform/src/views/submit/index.vue': '/budget-execution'
  }
  
  // 根据模块key映射到对应的路由路径
  const routeMapping: { [key: string]: string } = {
    // 基础财务报表 - 主要版本
    'balance_sheet': '/example',
    'cash_flow': '/cashflow', 
    'income_statement': '/incomestatement',
    'cost_center_structure': '/cost-center-structure-quality',
    'production_value': '/production-value',
    'project_tracking': '/projecttracking',
    
    // 财务分区 - newTable
    'business_income_structure': '/business-income-structure',
    'main_business_income': '/main-business-income',
    'order_to_income': '/order-to-income',
    'stock_order_to_income': '/stock-order-to-income',
    'non_main_business': '/non-main-business',
    'business_contribution': '/business-contribution',
    'business_profit_margin': '/business-profit-margin',
    'net_profit_structure': '/net-profit-structure',
    'main_business_net_profit': '/main-business-net-profit',
    'non_main_business_net_profit': '/non-main-business-net-profit',
    'receipt_structure': '/receipt-structure',
    'accounts_receivable': '/accounts-receivable',
    'overdue_receivables': '/overdue-receivables',
    'bad_debt_provision': '/bad-debt-provision',
    
    // 营销分区 - newTable
    'new_orders': '/new-orders',
    'bidding_status': '/bidding-status',
    'bid_fulfillment': '/bid-fulfillment',
    'inventory_structure': '/inventory-structure',
    'inventory_in_progress': '/inventory-in-progress',
    'main_business_cost': '/main-business-cost',
    'contract_inventory': '/contract-inventory',
    'cost_estimation': '/cost-estimation',
    
    // 生产分区 - newTable
    'production_value_analysis': '/production-value-analysis',
    'production_plan_execution': '/production-plan-execution',
    'production_execution_analysis': '/production-execution-analysis',
    
    // 企管分区 - newTable
    'department_cost_center': '/department-cost-center',
    'department_cost_input': '/department-cost-input',
    'major_investment_analysis': '/major-investment-analysis',
    'budget_execution': '/budget-execution'
  }
  
  // 首先尝试根据module_key查找路由
  if (routeMapping[module.module_key]) {
    console.log(`通过key映射导航到模块: ${module.module_name}, 路径: ${routeMapping[module.module_key]}`)
    router.push({
      path: routeMapping[module.module_key],
      query: { period: selectedPeriod.value }
    })
    return
  }
  
  // 如果有配置的路由路径，检查是否需要修正
  if (module.route_path && module.route_path !== '/') {
    const correctedPath = pathCorrections[module.route_path] || module.route_path
    console.log(`通过路径导航到模块: ${module.module_name}, 路径: ${correctedPath}`)
    router.push({
      path: correctedPath,
      query: { period: selectedPeriod.value }
    })
  } else {
    // 最后尝试根据module_key生成路由
    const kebabCaseKey = module.module_key.replace(/_/g, '-')
    console.log(`通过生成路径导航到模块: ${module.module_name}, 路径: /${kebabCaseKey}`)
    router.push({
      path: `/${kebabCaseKey}`,
      query: { period: selectedPeriod.value }
    })
  }
}

// 加载所有数据
const loadData = async () => {
  loading.value = true
  await Promise.all([
    fetchUserModules(),
    fetchSubmissions(),
    fetchPendingForms()
  ])
  loading.value = false
}

// 监听期间变化
watch(selectedPeriod, () => {
  fetchSubmissions()
  fetchPendingForms()
})

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>