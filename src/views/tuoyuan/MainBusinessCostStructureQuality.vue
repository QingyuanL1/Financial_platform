<template>
    <div class="max-w-[1500px] mx-auto bg-white rounded-lg shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">主营业务成本结构与质量（按年度口径分解）</h1>
            <div class="flex items-center space-x-4">
                <span class="text-sm text-gray-600">（单位：万元）</span>
                <span class="text-xs text-gray-500">本年累计=前面各月当期值之和</span>
                <input v-model="period" type="month" class="px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="overflow-x-auto my-6">
            <table class="w-full border-collapse border border-gray-300">
                <thead class="sticky top-0 bg-white">
                    <tr class="bg-gray-50">
                        <th class="border border-gray-300 px-4 py-2 w-24">板块</th>
                        <th class="border border-gray-300 px-4 py-2 w-32">客户属性</th>
                        <th class="border border-gray-300 px-4 py-2 w-28">年度计划</th>
                        <th class="border border-gray-300 px-4 py-2 w-28">当期</th>
                        <th class="border border-gray-300 px-4 py-2 w-28">本年累计</th>
                        <th class="border border-gray-300 px-4 py-2 w-28">计划执行进度</th>
                        <th class="border border-gray-300 px-4 py-2 w-28">占主营收入比</th>
                    </tr>
                </thead>
                <tbody>
                    <template v-for="(item, index) in costStructureData.items" :key="`cost-${index}`">
                        <tr>
                            <td v-if="isFirstInSegment(index)" 
                                :rowspan="getSegmentRowspan(item.segmentAttribute)" 
                                class="border border-gray-300 px-4 py-2 font-medium text-center">
                                {{ item.segmentAttribute }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.customerAttribute }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">{{ formatNumber(item.yearlyPlan) }}</td>
                            <td class="border border-gray-300 px-4 py-2">
                                <input 
                                    v-model="item.currentPeriod" 
                                    type="number" 
                                    class="w-full px-2 py-1 border rounded text-right" 
                                    step="0.01"
                                />
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">{{ formatNumber(item.yearlyAccumulated) }}</td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                <span class="text-sm font-medium">{{ formatPercentage(item.yearlyPlanCompletionRate) }}%</span>
                            </td>
                            <td class="border border-gray-300 px-4 py-2 text-right">
                                <span class="text-sm font-medium">{{ formatPercentage(item.cumulativeRatio) }}%</span>
                            </td>
                        </tr>
                    </template>

                    <!-- 合计行 -->
                    <tr class="bg-gray-50 font-bold">
                        <td colspan="2" class="border border-gray-300 px-4 py-2 text-center">合计</td>
                        <td class="border border-gray-300 px-4 py-2 text-right">{{ formatNumber(totalData.yearlyPlan) }}</td>
                        <td class="border border-gray-300 px-4 py-2 text-right">{{ formatNumber(totalData.currentPeriod) }}</td>
                        <td class="border border-gray-300 px-4 py-2 text-right">{{ formatNumber(totalData.yearlyAccumulated) }}</td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            <span class="text-sm font-bold">{{ formatPercentage(totalData.yearlyPlanCompletionRate) }}%</span>
                        </td>
                        <td class="border border-gray-300 px-4 py-2 text-right">
                            <span class="text-sm font-bold">100.00%</span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- 文件上传和备注组件 -->
        <FormAttachmentAndRemarks 
            :module-id="MODULE_IDS.TUOYUAN_MAIN_BUSINESS_COST_STRUCTURE_QUALITY"
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

interface CostStructureItem {
    segmentAttribute: string;
    customerAttribute: string;
    yearlyPlan: number;
    currentPeriod: number;
    yearlyAccumulated: number;
    yearlyPlanCompletionRate: number;
    cumulativeRatio: number;
}

interface CostStructureData {
    items: CostStructureItem[];
}

const fixedPlanData: CostStructureData = {
    items: [
        { segmentAttribute: '设备', customerAttribute: '电业项目', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 },
        { segmentAttribute: '设备', customerAttribute: '用户项目', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 },
        { segmentAttribute: '设备', customerAttribute: '贸易', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 },
        { segmentAttribute: '设备', customerAttribute: '代理设备', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 },
        { segmentAttribute: '设备', customerAttribute: '代理工程', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 },
        { segmentAttribute: '设备', customerAttribute: '代理设计', yearlyPlan: 0, currentPeriod: 0, yearlyAccumulated: 0, yearlyPlanCompletionRate: 0, cumulativeRatio: 0 }
    ]
}

const costStructureData = ref<CostStructureData>(JSON.parse(JSON.stringify(fixedPlanData)))
const remarks = ref('')
const suggestions = ref('')

const formatNumber = (value: number): string => {
    if (value === 0) return '0.00'
    return value.toFixed(2)
}

const formatPercentage = (value: number): string => {
    if (value === 0) return '0.00'
    return value.toFixed(2)
}

// 判断是否是板块的第一行
const isFirstInSegment = (index: number): boolean => {
    if (index === 0) return true
    return costStructureData.value.items[index].segmentAttribute !== costStructureData.value.items[index - 1].segmentAttribute
}

// 计算板块的行数
const getSegmentRowspan = (segmentAttribute: string): number => {
    return costStructureData.value.items.filter(item => item.segmentAttribute === segmentAttribute).length
}

// 计算本年累计
const calculateYearlyAccumulated = async (targetPeriod: string) => {
    try {
        const [year] = targetPeriod.split('-')
        const currentMonth = parseInt(targetPeriod.split('-')[1])
        
        // 为每个成本项目计算本年累计
        for (let item of costStructureData.value.items) {
            let totalCurrentPeriod = 0
            
            // 从1月累计到当前月份的所有当期值
            for (let m = 1; m <= currentMonth; m++) {
                const monthPeriod = `${year}-${m.toString().padStart(2, '0')}`
                try {
                    const response = await fetch(`http://47.111.95.19:3000/tuoyuan-main-business-cost-structure-quality/${monthPeriod}`)
                    if (response.ok) {
                        const result = await response.json()
                        const costData = result.data.items.find((c: any) => 
                            c.segmentAttribute === item.segmentAttribute && 
                            c.customerAttribute === item.customerAttribute
                        )
                        if (costData) {
                            totalCurrentPeriod += costData.currentPeriod || 0
                        }
                    }
                } catch (error) {
                    console.warn(`无法加载${monthPeriod}的数据:`, error)
                }
            }
            
            item.yearlyAccumulated = totalCurrentPeriod
            
            // 计算年度计划完成率 = 本年累计 / 年度计划 * 100%
            item.yearlyPlanCompletionRate = item.yearlyPlan > 0 ? (item.yearlyAccumulated / item.yearlyPlan) * 100 : 0
        }
        
        // 计算累计占比
        const totalYearlyAccumulated = costStructureData.value.items.reduce((sum, item) => sum + item.yearlyAccumulated, 0)
        costStructureData.value.items.forEach(item => {
            item.cumulativeRatio = totalYearlyAccumulated > 0 ? (item.yearlyAccumulated / totalYearlyAccumulated) * 100 : 0
        })
        
    } catch (error) {
        console.error('计算本年累计失败:', error)
    }
}

// 监听数据变化，自动重新计算累计值
watch(() => costStructureData.value.items, async (newItems) => {
    await calculateYearlyAccumulated(period.value)
}, { deep: true })

// 计算合计数据
const totalData = computed(() => {
    const total = {
        yearlyPlan: 0,
        currentPeriod: 0,
        yearlyAccumulated: 0,
        yearlyPlanCompletionRate: 0
    }
    
    costStructureData.value.items.forEach(item => {
        total.yearlyPlan += item.yearlyPlan || 0
        total.currentPeriod += item.currentPeriod || 0
        total.yearlyAccumulated += item.yearlyAccumulated || 0
    })
    
    // 计算总年度计划完成率
    total.yearlyPlanCompletionRate = total.yearlyPlan > 0 ? (total.yearlyAccumulated / total.yearlyPlan) * 100 : 0
    
    return total
})

// 加载数据
const loadData = async (targetPeriod: string) => {
    try {
        const response = await fetch(`http://47.111.95.19:3000/tuoyuan-main-business-cost-structure-quality/${targetPeriod}`)
        if (!response.ok) {
            if (response.status !== 404) {
                throw new Error('加载数据失败')
            }
            console.log(`${targetPeriod}期间无数据，重置为默认状态`)
            resetToDefaultData()
            return
        }
        const result = await response.json()
        if (result.data && result.data.items) {
            costStructureData.value.items = result.data.items.map((item: any) => ({
                segmentAttribute: item.segmentAttribute,
                customerAttribute: item.customerAttribute,
                yearlyPlan: Number(item.yearlyPlan) || 0,
                currentPeriod: Number(item.currentPeriod) || 0,
                yearlyAccumulated: Number(item.yearlyAccumulated) || 0,
                yearlyPlanCompletionRate: Number(item.yearlyPlanCompletionRate) || 0,
                cumulativeRatio: Number(item.cumulativeRatio) || 0
            }))
        }
        
        // 加载完数据后重新计算累计值
        await calculateYearlyAccumulated(targetPeriod)
    } catch (error) {
        console.error('加载数据失败:', error)
        resetToDefaultData()
    }
}

const resetToDefaultData = () => {
    costStructureData.value = JSON.parse(JSON.stringify(fixedPlanData))
}

// 加载备注和建议
const loadRemarksAndSuggestions = async (targetPeriod: string) => {
    try {
        const response = await fetch(`http://47.111.95.19:3000/forms/submission/${MODULE_IDS.TUOYUAN_MAIN_BUSINESS_COST_STRUCTURE_QUALITY}/${targetPeriod}`)
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

watch(() => route.query.period, async (newPeriod) => {
    if (newPeriod) {
        period.value = newPeriod.toString()
        resetToDefaultData()
        await loadData(newPeriod.toString())
        await calculateYearlyAccumulated(newPeriod.toString())
        loadRemarksAndSuggestions(newPeriod.toString())
    }
})

watch(period, async (newPeriod, oldPeriod) => {
    if (newPeriod && newPeriod !== oldPeriod) {
        console.log(`期间发生变化: ${oldPeriod} -> ${newPeriod}`)
        resetToDefaultData()
        await loadData(newPeriod)
        await calculateYearlyAccumulated(newPeriod)
        loadRemarksAndSuggestions(newPeriod)
    }
})

const handleSave = async () => {
    try {
        const response = await fetch('http://47.111.95.19:3000/tuoyuan-main-business-cost-structure-quality', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                period: period.value,
                data: {
                    items: costStructureData.value.items
                }
            })
        })

        if (!response.ok) {
            throw new Error('保存失败')
        }

        await recordFormSubmission(MODULE_IDS.TUOYUAN_MAIN_BUSINESS_COST_STRUCTURE_QUALITY, period.value, { items: costStructureData.value.items }, remarks.value, suggestions.value)
        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败')
    }
}

const handleReset = () => {
    resetToDefaultData()
    remarks.value = ''
    suggestions.value = ''
}

onMounted(async () => {
    resetToDefaultData()
    const targetPeriod = route.query.period?.toString() || period.value
    await loadData(targetPeriod)
    await calculateYearlyAccumulated(targetPeriod)
    loadRemarksAndSuggestions(targetPeriod)
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