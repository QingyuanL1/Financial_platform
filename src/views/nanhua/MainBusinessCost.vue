<template>
    <div class="max-w-[1500px] mx-auto bg-white rounded-lg shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">主营业务成本结构与质量</h1>
            <div class="flex items-center space-x-4">
                <span class="text-sm text-gray-600">（按年度计划口径分解）</span>
            </div>
        </div>

        <div class="mb-4">
            <h2 class="text-lg font-semibold mb-2">对应年度计划：</h2>
            <div class="flex items-center space-x-4">
                <span class="text-sm text-gray-600">（单位：万元）</span>
                <input v-model="period" type="month" class="px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="overflow-x-auto my-6">
            <table class="w-full border-collapse border border-gray-300">
                <thead class="sticky top-0 bg-white">
                    <tr class="bg-gray-50">
                        <th class="border border-gray-300 px-4 py-2">板块</th>
                        <th class="border border-gray-300 px-4 py-2">客户属性</th>
                        <th class="border border-gray-300 px-4 py-2">年度计划</th>
                        <th class="border border-gray-300 px-4 py-2">当期</th>
                        <th class="border border-gray-300 px-4 py-2">累计</th>
                        <th class="border border-gray-300 px-4 py-2">计划执行进度</th>
                        <th class="border border-gray-300 px-4 py-2">占主营收入比</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- 客户列表 -->
                    <template v-for="(item, index) in costData.customers" :key="`customer-${index}`">
                        <tr>
                            <td v-if="index === 0" :rowspan="costData.customers.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                工程
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.customerName }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                {{ formatNumber(item.yearlyPlan) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                <input v-model="item.current" type="number" class="w-full px-2 py-1 border rounded text-right" step="0.01" />
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                {{ formatNumber(item.accumulated) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                <span class="text-sm font-medium">{{ calculateProgress(item.yearlyPlan, item.accumulated) }}%</span>
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                <span class="text-sm font-medium">{{ formatNumber(item.revenueRatio) }}%</span>
                            </td>
                        </tr>
                    </template>

                    <!-- 合计行 -->
                    <tr class="bg-gray-50 font-bold">
                        <td colspan="2" class="border border-gray-300 px-4 py-2 text-center">合计</td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            {{ formatNumber(totalData.yearlyPlan) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            {{ formatNumber(totalData.current) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            {{ formatNumber(totalData.accumulated) }}
                        </td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            <span class="text-sm font-bold">{{ calculateProgress(totalData.yearlyPlan, totalData.accumulated) }}%</span>
                        </td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            <span class="text-sm font-bold">{{ formatNumber(totalData.revenueRatio) }}%</span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- 文件上传和备注组件 -->
        <FormAttachmentAndRemarks 
            :module-id="MODULE_IDS.NANHUA_MAIN_BUSINESS_COST"
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
import { recordFormSubmission, MODULE_IDS } from '@/utils/formSubmissionHelper'
import FormAttachmentAndRemarks from '@/components/FormAttachmentAndRemarks.vue'

const route = useRoute()
const period = ref(route.query.period?.toString() || new Date().toISOString().slice(0, 7))

interface CostItem {
    customerName: string;
    yearlyPlan: number;
    current: number;
    accumulated: number;
    revenueRatio: number;
}

interface CostData {
    customers: CostItem[];
}

// 固定的年度计划数据
const fixedPlanData: CostData = {
    customers: [
        { customerName: '一包项目', yearlyPlan: 4576.40, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '二包项目', yearlyPlan: 2441.97, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '域内合作项目', yearlyPlan: 3831.93, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '域外合作项目', yearlyPlan: 2410.82, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '新能源项目', yearlyPlan: 3098.65, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '苏州项目', yearlyPlan: 707.15, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '抢修项目', yearlyPlan: 183.74, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '运检项目', yearlyPlan: 1070.12, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '设备外服', yearlyPlan: 242.25, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '派遣', yearlyPlan: 207.07, current: 0, accumulated: 0, revenueRatio: 0 },
        { customerName: '自建项目', yearlyPlan: 0.00, current: 0, accumulated: 0, revenueRatio: 0 }
    ]
}

const costData = ref<CostData>(JSON.parse(JSON.stringify(fixedPlanData)))

// 备注和建议
const remarks = ref('')
const suggestions = ref('')

// 格式化数字显示
const formatNumber = (value: number): string => {
    if (value === 0) return '0.00'
    return value.toFixed(2)
}

// 计算执行进度
const calculateProgress = (yearlyPlan: number, accumulated: number): string => {
    if (!yearlyPlan || yearlyPlan === 0) return '0.00'
    return ((accumulated / yearlyPlan) * 100).toFixed(2)
}

// 计算合计数据
const totalData = computed(() => {
    const total = {
        yearlyPlan: 0,
        current: 0,
        accumulated: 0,
        revenueRatio: 0
    }
    
    costData.value.customers.forEach(item => {
        total.yearlyPlan += item.yearlyPlan || 0
        total.current += item.current || 0
        total.accumulated += item.accumulated || 0
        total.revenueRatio += item.revenueRatio || 0
    })
    
    return total
})

// 加载数据
const loadData = async (targetPeriod: string) => {
    try {
        const response = await fetch(`http://47.111.95.19:3000/nanhua-main-business-cost/${targetPeriod}`)
        if (!response.ok) {
            if (response.status !== 404) {
                throw new Error('加载数据失败')
            }
            return
        }
        const result = await response.json()
        if (result.data && result.data.customers) {
            // 直接使用后端返回的数据
            costData.value.customers = result.data.customers.map((item: any) => ({
                customerName: item.customerName,
                yearlyPlan: Number(item.yearlyPlan) || 0,
                current: Number(item.current) || 0,
                accumulated: Number(item.accumulated) || 0,
                revenueRatio: Number(item.revenueRatio) || 0
            }))
        }
    } catch (error) {
        console.error('加载数据失败:', error)
    }
}

// 加载已保存的备注和建议
const loadRemarksAndSuggestions = async (targetPeriod: string) => {
    try {
        const response = await fetch(`http://47.111.95.19:3000/forms/submission/${MODULE_IDS.NANHUA_MAIN_BUSINESS_COST}/${targetPeriod}`)
        if (response.ok) {
            const result = await response.json()
            if (result.success && result.data) {
                remarks.value = result.data.remarks || ''
                suggestions.value = result.data.suggestions || ''
            }
        }
    } catch (error) {
        console.error('加载备注失败:', error)
    }
}

// 计算累计数据（从年初到当前月份）
const calculateAccumulated = async (targetPeriod: string) => {
    try {
        const [year, month] = targetPeriod.split('-')
        const currentMonth = parseInt(month)

        // 为每个客户计算累计值
        for (let customer of costData.value.customers) {
            let accumulated = 0

            // 从1月累计到当前月份
            for (let m = 1; m <= currentMonth; m++) {
                const monthPeriod = `${year}-${m.toString().padStart(2, '0')}`
                try {
                    const response = await fetch(`http://47.111.95.19:3000/nanhua-main-business-cost/${monthPeriod}`)
                    if (response.ok) {
                        const result = await response.json()
                        const customerData = result.data.customers.find((c: any) => c.customerName === customer.customerName)
                        if (customerData) {
                            accumulated += customerData.current || 0
                        }
                    }
                } catch (error) {
                    console.warn(`无法加载${monthPeriod}的数据:`, error)
                }
            }

            customer.accumulated = accumulated
        }
    } catch (error) {
        console.error('计算累计数据失败:', error)
    }
}

// 监听路由参数变化
watch(() => route.query.period, async (newPeriod) => {
    if (newPeriod) {
        period.value = newPeriod.toString()
        await loadData(newPeriod.toString())
        await calculateAccumulated(newPeriod.toString())
        loadRemarksAndSuggestions(newPeriod.toString())
    }
})

// 监听期间变化，重新加载数据和备注
watch(period, async (newPeriod, oldPeriod) => {
    if (newPeriod && newPeriod !== oldPeriod) {
        console.log(`期间发生变化: ${oldPeriod} -> ${newPeriod}`)
        await loadData(newPeriod)
        await calculateAccumulated(newPeriod)
        loadRemarksAndSuggestions(newPeriod)
    }
})

const handleSave = async () => {
    try {
        const response = await fetch('http://47.111.95.19:3000/nanhua-main-business-cost', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                period: period.value,
                data: costData.value
            })
        })

        if (!response.ok) {
            throw new Error('保存失败')
        }

        // 记录提交状态（包含备注和建议）
        await recordFormSubmission(MODULE_IDS.NANHUA_MAIN_BUSINESS_COST, period.value, costData.value, remarks.value, suggestions.value)

        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败')
    }
}

const handleReset = () => {
    costData.value = JSON.parse(JSON.stringify(fixedPlanData))
    remarks.value = ''
    suggestions.value = ''
}

onMounted(async () => {
    if (route.query.period) {
        await loadData(route.query.period.toString())
        await calculateAccumulated(route.query.period.toString())
        loadRemarksAndSuggestions(route.query.period.toString())
    } else {
        await loadData(period.value)
        await calculateAccumulated(period.value)
        loadRemarksAndSuggestions(period.value)
    }
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
