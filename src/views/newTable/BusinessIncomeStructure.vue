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

        <!-- 主营业务收入分解情况表 -->
        <div class="mt-8">
            <h2 class="text-xl font-bold mb-4">主营业务收入分解情况（单位：万元）</h2>
            <div class="overflow-x-auto my-6">
                <table class="w-full border-collapse border border-gray-300">
                    <thead class="sticky top-0 bg-white">
                        <tr class="bg-gray-50">
                            <th class="border border-gray-300 px-4 py-2">板块</th>
                            <th class="border border-gray-300 px-4 py-2">客户属性</th>
                            <th class="border border-gray-300 px-4 py-2">年度计划</th>
                            <th class="border border-gray-300 px-4 py-2">当月收入</th>
                            <th class="border border-gray-300 px-4 py-2">累计收入</th>
                            <th class="border border-gray-300 px-4 py-2">执行进度</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- 设备类别 -->
                        <template v-for="(item, index) in mainBusinessIncomeData.equipment" :key="`equipment-${index}`">
                            <tr>
                                <td v-if="index === 0" :rowspan="mainBusinessIncomeData.equipment.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                    设备
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.customer }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ typeof item.yearlyPlan === 'number' ? formatNumber(item.yearlyPlan) : item.yearlyPlan }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <input v-model.number="item.currentMonthIncome" type="number" class="w-full px-2 py-1 border rounded" step="0.01" />
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <span class="font-medium">{{ item.accumulatedIncome.toFixed(2) }}</span>
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.progress }}
                                </td>
                            </tr>
                        </template>

                        <!-- 元件类别 -->
                        <template v-for="(item, index) in mainBusinessIncomeData.components" :key="`components-${index}`">
                            <tr>
                                <td v-if="index === 0" :rowspan="mainBusinessIncomeData.components.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                    元件
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.customer }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ typeof item.yearlyPlan === 'number' ? formatNumber(item.yearlyPlan) : item.yearlyPlan }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <input v-model.number="item.currentMonthIncome" type="number" class="w-full px-2 py-1 border rounded" step="0.01" />
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <span class="font-medium">{{ item.accumulatedIncome.toFixed(2) }}</span>
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.progress }}
                                </td>
                            </tr>
                        </template>

                        <!-- 工程类别 -->
                        <template v-for="(item, index) in mainBusinessIncomeData.engineering" :key="`engineering-${index}`">
                            <tr>
                                <td v-if="index === 0" :rowspan="mainBusinessIncomeData.engineering.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                    工程
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.customer }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ typeof item.yearlyPlan === 'number' ? formatNumber(item.yearlyPlan) : item.yearlyPlan }}
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <input v-model.number="item.currentMonthIncome" type="number" class="w-full px-2 py-1 border rounded" step="0.01" />
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    <span class="font-medium">{{ item.accumulatedIncome.toFixed(2) }}</span>
                                </td>
                                <td class="border border-gray-300 px-4 py-2">
                                    {{ item.progress }}
                                </td>
                            </tr>
                        </template>

                        <!-- 合计行 -->
                        <tr class="bg-gray-50 font-bold">
                            <td class="border border-gray-300 px-4 py-2 text-center" colspan="2">合计</td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ mainBusinessIncomeTotalData.yearlyPlan.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ mainBusinessIncomeTotalData.currentMonthIncome.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ mainBusinessIncomeTotalData.accumulatedIncome.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ mainBusinessIncomeTotalData.progress }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 非主营业务情况表 -->
        <div class="mt-8">
            <h2 class="text-xl font-bold mb-4">非主营业务情况（单位：万元）</h2>
            <div class="overflow-x-auto my-6">
                <table class="w-full border-collapse border border-gray-300">
                    <thead class="sticky top-0 bg-white">
                        <tr class="bg-gray-50">
                            <th class="border border-gray-300 px-4 py-2 w-24">序号</th>
                            <th class="border border-gray-300 px-4 py-2">财务科目</th>
                            <th class="border border-gray-300 px-4 py-2">年度计划</th>
                            <th class="border border-gray-300 px-4 py-2">当期</th>
                            <th class="border border-gray-300 px-4 py-2">累计</th>
                            <th class="border border-gray-300 px-4 py-2">执行进度</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(item, index) in nonMainBusinessData" :key="index">
                            <td class="border border-gray-300 px-4 py-2 text-center">
                                {{ item.id }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.category }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                <input v-model.number="item.yearlyPlan" type="number" class="w-full px-2 py-1 border rounded bg-gray-100" step="0.01" readonly />
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                <input v-model.number="item.currentPeriod" type="number" class="w-full px-2 py-1 border rounded" step="0.01" />
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                <span class="font-medium">{{ formatNumber(item.cumulative) }}</span>
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ calculateNonMainProgress(item.yearlyPlan, item.cumulative) }}%
                            </td>
                        </tr>

                        <!-- 合计行 -->
                        <tr class="bg-gray-50 font-bold">
                            <td class="border border-gray-300 px-4 py-2 text-center">合计</td>
                            <td class="border border-gray-300 px-4 py-2"></td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ nonMainBusinessTotalData.yearlyPlan.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ nonMainBusinessTotalData.currentPeriod.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ nonMainBusinessTotalData.cumulative.toFixed(2) }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ nonMainBusinessTotalData.progress }}%
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
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

// 主营业务收入数据接口
interface MainBusinessIncomeItem {
    customer: string;
    yearlyPlan: number | string;
    currentMonthIncome: number;
    accumulatedIncome: number;
    progress: string;
}

interface MainBusinessIncomeData {
    equipment: MainBusinessIncomeItem[];
    components: MainBusinessIncomeItem[];
    engineering: MainBusinessIncomeItem[];
}

// 非主营业务数据接口
interface NonMainBusinessItem {
    id: number;
    category: string;
    yearlyPlan: number;
    currentPeriod: number;
    cumulative: number;
}

// 初始数据模板（当没有数据时使用）
const getInitialData = (): IncomeItem[] => [
    { id: 1, category: '主营业务', yearlyPlan: 59400, currentMonthIncome: 0, accumulatedIncome: 0 },
    { id: 2, category: '非主营业务', yearlyPlan: 600, currentMonthIncome: 0, accumulatedIncome: 0 }
]

// 主营业务收入初始数据
const getInitialMainBusinessIncomeData = (): MainBusinessIncomeData => {
    return {
        equipment: [
            { customer: '上海', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '国网', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '江苏', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '输配电内配', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '西门子', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '同业', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '用户', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '其它', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' }
        ],
        components: [
            { customer: '用户', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' }
        ],
        engineering: [
            { customer: '一包', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '二包', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '域内合作', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '域外合作', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' },
            { customer: '其它', yearlyPlan: 0, currentMonthIncome: 0, accumulatedIncome: 0, progress: '0.00%' }
        ]
    }
}

// 非主营业务初始数据
const getInitialNonMainBusinessData = (): NonMainBusinessItem[] => [
    { id: 1, category: '固定收入', yearlyPlan: 100, currentPeriod: 0, cumulative: 0 },
    { id: 2, category: '房屋租金', yearlyPlan: 0, currentPeriod: 0, cumulative: 0 },
    { id: 3, category: '利息收入', yearlyPlan: 0, currentPeriod: 0, cumulative: 0 },
    { id: 4, category: '投资收益', yearlyPlan: 0, currentPeriod: 0, cumulative: 0 },
    { id: 5, category: '补贴收入', yearlyPlan: 0, currentPeriod: 0, cumulative: 0 },
    { id: 6, category: '其他', yearlyPlan: 0, currentPeriod: 0, cumulative: 0 },
]

const incomeData = ref<IncomeItem[]>(getInitialData())
const mainBusinessIncomeData = ref<MainBusinessIncomeData>(getInitialMainBusinessIncomeData())
const nonMainBusinessData = ref<NonMainBusinessItem[]>(getInitialNonMainBusinessData())

// 备注和建议
const remarks = ref('')
const suggestions = ref('')

// 格式化数字函数
const formatNumber = (num: number): string => {
    if (isNaN(num)) return '0.00'
    return num.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

// 计算进度函数
const calculateProgress = (yearlyPlan: number, accumulatedIncome: number): string => {
  if (!yearlyPlan || yearlyPlan === 0) return '0.00'
  const progress = (accumulatedIncome / yearlyPlan) * 100
  return progress.toFixed(2)
}

// 计算非主营业务进度
const calculateNonMainProgress = (yearlyPlan: number, cumulative: number): string => {
    if (!yearlyPlan || yearlyPlan === 0) return '0.00'
    const progress = (cumulative / yearlyPlan) * 100
    return progress.toFixed(2)
}

// 计算主营业务收入合计数据
const mainBusinessIncomeTotalData = computed(() => {
    let totalYearlyPlan = 0
    let totalCurrentMonth = 0
    let totalAccumulated = 0

    // 计算设备板块合计
    mainBusinessIncomeData.value.equipment.forEach(item => {
        const yearlyPlan = typeof item.yearlyPlan === 'number' ? item.yearlyPlan : 0
        totalYearlyPlan += yearlyPlan
        totalCurrentMonth += item.currentMonthIncome || 0
        totalAccumulated += item.accumulatedIncome || 0
    })

    // 计算元件板块合计
    mainBusinessIncomeData.value.components.forEach(item => {
        const yearlyPlan = typeof item.yearlyPlan === 'number' ? item.yearlyPlan : 0
        totalYearlyPlan += yearlyPlan
        totalCurrentMonth += item.currentMonthIncome || 0
        totalAccumulated += item.accumulatedIncome || 0
    })

    // 计算工程板块合计
    mainBusinessIncomeData.value.engineering.forEach(item => {
        const yearlyPlan = typeof item.yearlyPlan === 'number' ? item.yearlyPlan : 0
        totalYearlyPlan += yearlyPlan
        totalCurrentMonth += item.currentMonthIncome || 0
        totalAccumulated += item.accumulatedIncome || 0
    })

    const progress = totalYearlyPlan > 0 ? ((totalAccumulated / totalYearlyPlan) * 100).toFixed(2) + '%' : '0.00%'

    return {
        yearlyPlan: totalYearlyPlan,
        currentMonthIncome: totalCurrentMonth,
        accumulatedIncome: totalAccumulated,
        progress: progress
    }
})

// 计算非主营业务合计数据
const nonMainBusinessTotalData = computed(() => {
    let totalYearlyPlan = 0
    let totalCurrentPeriod = 0
    let totalCumulative = 0

    nonMainBusinessData.value.forEach(item => {
        totalYearlyPlan += item.yearlyPlan || 0
        totalCurrentPeriod += item.currentPeriod || 0
        totalCumulative += item.cumulative || 0
    })

    const progress = totalYearlyPlan > 0 ? ((totalCumulative / totalYearlyPlan) * 100).toFixed(2) : '0.00'

    return {
        yearlyPlan: totalYearlyPlan,
        currentPeriod: totalCurrentPeriod,
        cumulative: totalCumulative,
        progress: progress
    }
})

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

        // 加载主营业务收入数据
        await loadMainBusinessIncomeData(targetPeriod)

        // 加载非主营业务数据
        await loadNonMainBusinessData(targetPeriod)

    } catch (error) {
        console.error('加载数据失败:', error)
        incomeData.value = getInitialData()
    }
}

// 加载主营业务收入数据
const loadMainBusinessIncomeData = async (targetPeriod: string) => {
    try {
        console.log(`正在加载主营业务收入数据，期间: ${targetPeriod}`)

        const response = await fetch(`http://47.111.95.19:3000/main-business-income/${targetPeriod}`)
        if (!response.ok) {
            if (response.status === 404) {
                console.log('该期间暂无主营业务收入数据，使用初始模板')
                mainBusinessIncomeData.value = getInitialMainBusinessIncomeData()
                return
            }
            throw new Error('加载主营业务收入数据失败')
        }

        const result = await response.json()
        console.log('主营业务收入API返回数据:', result)

        if (result.success && result.data) {
            const loadedData = result.data
            console.log('API返回的数据结构:', loadedData)

            // 合并数据：将从数据库加载的数据与初始模板合并
            const mergeDataArray = (templateArray: MainBusinessIncomeItem[], loadedArray: any[]) => {
                return templateArray.map(templateItem => {
                    const loadedItem = loadedArray.find((item: any) => item.customer === templateItem.customer)

                    if (loadedItem) {
                        return {
                            ...templateItem,
                            yearlyPlan: loadedItem.yearlyPlan || templateItem.yearlyPlan,
                            currentMonthIncome: loadedItem.currentMonthIncome || 0,
                            accumulatedIncome: loadedItem.accumulatedIncome || 0,
                            progress: loadedItem.progress || '0.00%'
                        }
                    }
                    return templateItem
                })
            }

            // 分别合并三个板块的数据
            if (loadedData.equipment && Array.isArray(loadedData.equipment)) {
                mainBusinessIncomeData.value.equipment = mergeDataArray(mainBusinessIncomeData.value.equipment, loadedData.equipment)
            }

            if (loadedData.components && Array.isArray(loadedData.components)) {
                mainBusinessIncomeData.value.components = mergeDataArray(mainBusinessIncomeData.value.components, loadedData.components)
            }

            if (loadedData.engineering && Array.isArray(loadedData.engineering)) {
                mainBusinessIncomeData.value.engineering = mergeDataArray(mainBusinessIncomeData.value.engineering, loadedData.engineering)
            }

            console.log('主营业务收入数据合并完成:', mainBusinessIncomeData.value)
        }
    } catch (error) {
        console.error('加载主营业务收入数据失败:', error)
        mainBusinessIncomeData.value = getInitialMainBusinessIncomeData()
    }
}

// 加载非主营业务数据
const loadNonMainBusinessData = async (targetPeriod: string) => {
    try {
        console.log(`正在加载非主营业务数据，期间: ${targetPeriod}`)

        const response = await fetch(`http://47.111.95.19:3000/non-main-business/${targetPeriod}`)
        if (!response.ok) {
            if (response.status === 404) {
                console.log('该期间暂无非主营业务数据，使用初始模板')
                nonMainBusinessData.value = getInitialNonMainBusinessData()
                return
            }
            throw new Error('加载非主营业务数据失败')
        }

        const result = await response.json()
        console.log('非主营业务API返回数据:', result)

        if (result.success && result.data && Array.isArray(result.data)) {
            const loadedData = result.data

            // 合并数据：将从数据库加载的数据与初始模板合并
            nonMainBusinessData.value = nonMainBusinessData.value.map(templateItem => {
                const loadedItem = loadedData.find((item: any) => item.id === templateItem.id)

                if (loadedItem) {
                    return {
                        ...templateItem,
                        yearlyPlan: loadedItem.yearlyPlan || templateItem.yearlyPlan,
                        currentPeriod: loadedItem.currentPeriod || 0,
                        cumulative: loadedItem.cumulative || 0
                    }
                }
                return templateItem
            })

            console.log('非主营业务数据合并完成:', nonMainBusinessData.value)
        }
    } catch (error) {
        console.error('加载非主营业务数据失败:', error)
        nonMainBusinessData.value = getInitialNonMainBusinessData()
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

        // 1. 保存营业收入结构数据到专用表
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
            throw new Error(`保存营业收入结构数据失败: ${response.status} - ${errorText}`)
        }

        // 2. 保存主营业务收入数据
        await saveMainBusinessIncomeData()

        // 3. 保存非主营业务数据
        await saveNonMainBusinessData()

        // 4. 保存到 form_submissions 表
        await recordFormSubmission(MODULE_IDS.BUSINESS_INCOME_STRUCTURE, period.value, incomeData.value, remarks.value, suggestions.value)

        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败: ' + (error instanceof Error ? error.message : '未知错误'))
    }
}

// 保存主营业务收入数据
const saveMainBusinessIncomeData = async () => {
    try {
        // 准备要保存的数据
        const allData = [
            ...mainBusinessIncomeData.value.equipment.map(item => ({ ...item, segment: '设备' })),
            ...mainBusinessIncomeData.value.components.map(item => ({ ...item, segment: '元件' })),
            ...mainBusinessIncomeData.value.engineering.map(item => ({ ...item, segment: '工程' }))
        ]

        const saveData = {
            period: period.value,
            data: allData
        }

        console.log('保存主营业务收入数据:', saveData)

        const response = await fetch('http://47.111.95.19:3000/main-business-income', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(saveData)
        })

        if (!response.ok) {
            const errorText = await response.text()
            throw new Error(`保存主营业务收入数据失败: ${response.status} - ${errorText}`)
        }

        // 保存到 form_submissions 表
        const formData = {
            equipment: mainBusinessIncomeData.value.equipment,
            components: mainBusinessIncomeData.value.components,
            engineering: mainBusinessIncomeData.value.engineering
        }
        await recordFormSubmission(MODULE_IDS.MAIN_BUSINESS_INCOME, period.value, formData, '', '')

    } catch (error) {
        console.error('保存主营业务收入数据失败:', error)
        throw error
    }
}

// 保存非主营业务数据
const saveNonMainBusinessData = async () => {
    try {
        const saveData = {
            period: period.value,
            data: nonMainBusinessData.value
        }

        console.log('保存非主营业务数据:', saveData)

        const response = await fetch('http://47.111.95.19:3000/non-main-business', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(saveData)
        })

        if (!response.ok) {
            const errorText = await response.text()
            throw new Error(`保存非主营业务数据失败: ${response.status} - ${errorText}`)
        }

        // 保存到 form_submissions 表
        await recordFormSubmission(MODULE_IDS.NON_MAIN_BUSINESS, period.value, nonMainBusinessData.value, '', '')

    } catch (error) {
        console.error('保存非主营业务数据失败:', error)
        throw error
    }
}

const handleReset = () => {
    incomeData.value = getInitialData()
    mainBusinessIncomeData.value = getInitialMainBusinessIncomeData()
    nonMainBusinessData.value = getInitialNonMainBusinessData()
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