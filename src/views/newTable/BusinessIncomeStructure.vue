<template>
    <div class="max-w-[1500px] mx-auto bg-white rounded-lg shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">营业收入结构与质量（单位：万元）</h1>
            <div class="flex items-center space-x-4">
                <input v-model="period" type="month" class="px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="overflow-x-auto my-6">
            <table class="w-full border-collapse border border-gray-300">
                <thead class="sticky top-0 bg-white">
                    <tr class="bg-gray-50">
                        <th class="border border-gray-300 px-4 py-2">序号</th>
                        <th class="border border-gray-300 px-4 py-2">财务科目</th>
                        <th class="border border-gray-300 px-4 py-2">年度计划</th>
                        <th class="border border-gray-300 px-4 py-2">当月收入</th>
                        <th class="border border-gray-300 px-4 py-2">累计收入</th>
                        <th class="border border-gray-300 px-4 py-2">执行进度</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(item, index) in incomeData" :key="index">
                        <td class="border border-gray-300 px-4 py-2 text-center">
                            {{ item.id }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ item.category }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ item.yearlyPlan.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ item.currentMonthIncome.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ item.accumulatedIncome.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <span class="text-sm font-medium">{{ calculateProgress(item.yearlyPlan, item.accumulatedIncome) }}%</span>
                        </td>
                    </tr>

                    <!-- 合计行 -->
                    <tr class="bg-gray-50 font-bold">
                        <td class="border border-gray-300 px-4 py-2 text-center">合计</td>
                        <td class="border border-gray-300 px-4 py-2"></td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ totalData.yearlyPlan.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ totalData.currentMonthIncome.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ totalData.accumulatedIncome.toFixed(2) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            {{ totalData.progress.toFixed(2) }}%
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- 文件上传和备注组件 -->
        <FormAttachmentAndRemarks 
            :module-id="MODULE_IDS.BUSINESS_INCOME_STRUCTURE"
            :period="period"
            v-model:remarks="remarks"
            v-model:suggestions="suggestions"
        />

        <div class="mt-4 flex justify-end space-x-4">
            <button @click="handleSave" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                保存
            </button>
            <button @click="handleReset" class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
                重置
            </button>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useRoute } from 'vue-router'
import { recordFormSubmission, loadRemarksAndSuggestions, MODULE_IDS } from '@/utils/formSubmissionHelper'
import FormAttachmentAndRemarks from '@/components/FormAttachmentAndRemarks.vue'

const route = useRoute()
const period = ref(route.query.period?.toString() || new Date().toISOString().slice(0, 7))

interface IncomeItem {
    id: number;
    category: string;
    yearlyPlan: number;
    currentMonthIncome: number;
    accumulatedIncome: number;
}

// 初始数据模板（当没有数据时使用）
const getInitialData = (): IncomeItem[] => [
    { id: 1, category: '主营业务', yearlyPlan: 59400, currentMonthIncome: 0, accumulatedIncome: 0 },
    { id: 2, category: '非主营业务', yearlyPlan: 600, currentMonthIncome: 0, accumulatedIncome: 0 }
]

const incomeData = ref<IncomeItem[]>(getInitialData())

// 备注和建议
const remarks = ref('')
const suggestions = ref('')

// 计算进度函数
const calculateProgress = (yearlyPlan: number, accumulatedIncome: number): string => {
  if (!yearlyPlan || yearlyPlan === 0) return '0.00'
  const progress = (accumulatedIncome / yearlyPlan) * 100
  return progress.toFixed(2)
}

// 计算合计数据
const totalData = computed(() => {
    const total = {
        yearlyPlan: 0,
        currentMonthIncome: 0,
        accumulatedIncome: 0,
        progress: 0
    }
    
    incomeData.value.forEach(item => {
        total.yearlyPlan += item.yearlyPlan || 0
        total.currentMonthIncome += item.currentMonthIncome || 0
        total.accumulatedIncome += item.accumulatedIncome || 0
    })
    
    // 计算总进度
    total.progress = total.yearlyPlan > 0 ? (total.accumulatedIncome / total.yearlyPlan * 100) : 0
    total.progress = parseFloat(total.progress.toFixed(2))
    
    return total
})

// 合并数据：将从数据库加载的数据与初始模板合并
const mergeData = (templateData: IncomeItem[], loadedData: any[]): IncomeItem[] => {
    if (!Array.isArray(loadedData) || loadedData.length === 0) {
        return templateData
    }
    
    return templateData.map(templateItem => {
        const loadedItem = loadedData.find(item => item.id === templateItem.id)
        if (loadedItem) {
            return {
                id: templateItem.id,
                category: templateItem.category,
                yearlyPlan: loadedItem.yearlyPlan || 0,
                currentMonthIncome: loadedItem.currentMonthIncome || 0,
                accumulatedIncome: loadedItem.accumulatedIncome || 0
            }
        }
        return templateItem
    })
}

// 加载数据
const loadData = async (targetPeriod: string) => {
    try {
        console.log(`正在加载营业收入结构数据，期间: ${targetPeriod}`)

        const response = await fetch(`http://47.111.95.19:3000/business-income/${targetPeriod}`)
        if (!response.ok) {
            if (response.status === 404) {
                console.log('该期间暂无数据，使用初始模板')
                incomeData.value = getInitialData()
                return
            }
            throw new Error('加载数据失败')
        }

        const result = await response.json()
        console.log('API返回数据:', result)

        if (result.success && result.data && Array.isArray(result.data)) {
            console.log('成功获取数据，直接使用后端计算的结果')
            incomeData.value = result.data.map((item: any) => ({
                id: item.id,
                category: item.category,
                yearlyPlan: item.id === 1 ? 59400 : 600, // 写死年度计划：主营业务59400，非主营业务600
                currentMonthIncome: item.currentMonthIncome || 0,
                accumulatedIncome: item.accumulatedIncome || 0
            }))
            console.log('处理后的数据:', incomeData.value)
        } else {
            console.log('数据格式不正确，使用初始模板')
            incomeData.value = getInitialData()
        }
    } catch (error) {
        console.error('加载数据失败:', error)
        incomeData.value = getInitialData()
    }
}

// 监听路由参数变化
watch(() => route.query.period, (newPeriod) => {
    if (newPeriod) {
        period.value = newPeriod.toString()
        loadData(newPeriod.toString())
        loadRemarksData()
    }
})

// 监听期间变化
watch(period, (newPeriod) => {
    loadData(newPeriod)
    loadRemarksData()
})

const handleSave = async () => {
    try {
        console.log('保存数据:', { period: period.value, data: incomeData.value })

        // 1. 保存到专用表
        const response = await fetch('http://47.111.95.19:3000/business-income', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                period: period.value,
                data: incomeData.value
            })
        })

        if (!response.ok) {
            const errorText = await response.text()
            throw new Error(`保存失败: ${response.status} - ${errorText}`)
        }

        // 2. 保存到 form_submissions 表
        await recordFormSubmission(MODULE_IDS.BUSINESS_INCOME_STRUCTURE, period.value, incomeData.value, remarks.value, suggestions.value)

        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败: ' + (error instanceof Error ? error.message : '未知错误'))
    }
}

const handleReset = () => {
    incomeData.value = getInitialData()
    remarks.value = ''
    suggestions.value = ''
    console.log('已重置为初始数据')
}

// 加载备注和建议
const loadRemarksData = async () => {
    const { remarks: loadedRemarks, suggestions: loadedSuggestions } = await loadRemarksAndSuggestions(MODULE_IDS.BUSINESS_INCOME_STRUCTURE, period.value)
    remarks.value = loadedRemarks
    suggestions.value = loadedSuggestions
}

onMounted(() => {
    console.log('营业收入结构组件挂载，当前期间:', period.value)
    if (route.query.period) {
        loadData(route.query.period.toString())
    } else {
        loadData(period.value)
    }
    loadRemarksData()
})
</script>

<style scoped>
.overflow-x-auto::-webkit-scrollbar {
    height: 6px;
}

.overflow-x-auto::-webkit-scrollbar-track {
    background: #f1f1f1;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}
</style> 