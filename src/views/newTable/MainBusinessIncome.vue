<template>
    <div class="max-w-[1500px] mx-auto bg-white rounded-lg shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">主营业务收入分解情况（单位：万元）</h1>
            <div class="flex items-center space-x-4">
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
                        <th class="border border-gray-300 px-4 py-2">当月收入</th>
                        <th class="border border-gray-300 px-4 py-2">累计收入</th>
                        <th class="border border-gray-300 px-4 py-2">执行进度</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- 设备类别 -->
                    <template v-for="(item, index) in incomeData.equipment" :key="`equipment-${index}`">
                        <tr>
                            <td v-if="index === 0" :rowspan="incomeData.equipment.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                设备
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.customer }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.yearlyPlan }}
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
                    <template v-for="(item, index) in incomeData.components" :key="`components-${index}`">
                        <tr>
                            <td v-if="index === 0" :rowspan="incomeData.components.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                元件
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.customer }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.yearlyPlan }}
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
                    <template v-for="(item, index) in incomeData.engineering" :key="`engineering-${index}`">
                        <tr>
                            <td v-if="index === 0" :rowspan="incomeData.engineering.length" class="border border-gray-300 px-4 py-2 font-medium text-center">
                                工程
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.customer }}
                            </td>
                            <td class="border border-gray-300 px-4 py-2">
                                {{ item.yearlyPlan }}
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
                        <td class="border border-gray-300 px-4 py-2 text-center">合计</td>
                        <td class="border border-gray-300 px-4 py-2"></td>
                        <td class="border border-gray-300 px-4 py-2">{{ yearlyPlanTotal }}</td>
                        <td class="border border-gray-300 px-4 py-2">{{ currentMonthTotal.toFixed(2) }}</td>
                        <td class="border border-gray-300 px-4 py-2">{{ accumulatedTotal.toFixed(2) }}</td>
                        <td class="border border-gray-300 px-4 py-2">{{ totalProgress }}</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- 文件上传和备注组件 -->
        <FormAttachmentAndRemarks 
            :module-id="MODULE_IDS.MAIN_BUSINESS_INCOME"
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
import FormAttachmentAndRemarks from '@/components/FormAttachmentAndRemarks.vue'
import { recordFormSubmission, MODULE_IDS, loadRemarksAndSuggestions } from '@/utils/formSubmissionHelper'

const route = useRoute()
const period = ref(route.query.period?.toString() || new Date().toISOString().slice(0, 7))

interface IncomeItem {
    customer: string;
    yearlyPlan: number | string;
    currentMonthIncome: number;
    accumulatedIncome: number;
    progress: string;
}

interface IncomeData {
    equipment: IncomeItem[];
    components: IncomeItem[];
    engineering: IncomeItem[];
}

// 获取初始数据模板
const getInitialData = (): IncomeData => {
    return {
        equipment: [
            { customer: '上海', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '国网', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '江苏', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '输配电内配', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '西门子', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '同业', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '用户', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '其它', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' }
        ],
        components: [
            { customer: '用户', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' }
        ],
        engineering: [
            { customer: '一包', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '二包', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '域内合作', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '域外合作', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' },
            { customer: '其它', yearlyPlan: '缺少数据', currentMonthIncome: 0, accumulatedIncome: 0, progress: '/' }
        ]
    }
}

// 数据合并函数
const mergeData = (defaultData: IncomeData, savedData: IncomeData): IncomeData => {
    const merged = JSON.parse(JSON.stringify(defaultData))
    
    // 合并设备数据
    if (savedData.equipment) {
        merged.equipment.forEach((item, index) => {
            if (savedData.equipment[index]) {
                Object.assign(item, savedData.equipment[index])
            }
        })
    }
    
    // 合并元件数据
    if (savedData.components) {
        merged.components.forEach((item, index) => {
            if (savedData.components[index]) {
                Object.assign(item, savedData.components[index])
            }
        })
    }
    
    // 合并工程数据
    if (savedData.engineering) {
        merged.engineering.forEach((item, index) => {
            if (savedData.engineering[index]) {
                Object.assign(item, savedData.engineering[index])
            }
        })
    }
    
    return merged
}

const incomeData = ref<IncomeData>(getInitialData())

// 存储所有历史月份数据，用于计算累计收入
const allMonthsData = ref<Array<{ period: string; data: IncomeData }>>([])

// 备注和建议
const remarks = ref('')
const suggestions = ref('')

// 加载所有月份数据（从年初到当前月份）
const loadAllMonthsData = async (currentPeriod: string) => {
    try {
        const allData: Array<{ period: string; data: IncomeData }> = []
        const currentYear = currentPeriod.substring(0, 4)
        const currentMonth = parseInt(currentPeriod.substring(5, 7))

        // 从1月到当前月份（不包括当前月份）
        for (let month = 1; month < currentMonth; month++) {
            const monthPeriod = `${currentYear}-${month.toString().padStart(2, '0')}`
            try {
                const response = await fetch(`http://47.111.95.19:3000/main-business-income/${monthPeriod}`)
                if (response.ok) {
                    const result = await response.json()
                    if (result.success && result.data) {
                        allData.push({ period: monthPeriod, data: result.data })
                    }
                }
            } catch (error) {
                console.log(`跳过月份 ${monthPeriod}:`, error)
            }
        }

        allMonthsData.value = allData
        console.log('加载的所有月份数据:', allData)
    } catch (error) {
        console.error('加载所有月份数据失败:', error)
    }
}

// 计算累计收入
const calculateAccumulatedIncome = (category: 'equipment' | 'components' | 'engineering', customer: string) => {
    let total = 0

    // 累加历史月份数据
    for (const monthData of allMonthsData.value) {
        const categoryData = monthData.data[category]
        if (categoryData) {
            const item = categoryData.find(d => d.customer === customer)
            if (item && item.currentMonthIncome) {
                total += item.currentMonthIncome
            }
        }
    }

    // 加上当前月份的输入值
    const currentCategoryData = incomeData.value[category]
    const currentItem = currentCategoryData.find(d => d.customer === customer)
    if (currentItem && currentItem.currentMonthIncome) {
        total += currentItem.currentMonthIncome
    }

    return total
}

// 更新累计收入数据
const updateAccumulatedIncome = () => {
    // 更新设备板块累计收入
    incomeData.value.equipment.forEach(item => {
        item.accumulatedIncome = calculateAccumulatedIncome('equipment', item.customer)
    })

    // 更新元件板块累计收入
    incomeData.value.components.forEach(item => {
        item.accumulatedIncome = calculateAccumulatedIncome('components', item.customer)
    })

    // 更新工程板块累计收入
    incomeData.value.engineering.forEach(item => {
        item.accumulatedIncome = calculateAccumulatedIncome('engineering', item.customer)
    })
}

// 计算执行进度
const calculateProgress = (yearlyPlan: number | string, accumulatedIncome: number): string => {
  if (yearlyPlan === '缺少数据' || !yearlyPlan) return '/'
  const planNumber = typeof yearlyPlan === 'string' ? parseFloat(yearlyPlan.replace(/,/g, '')) || 0 : yearlyPlan
  if (planNumber === 0) return '/'
  const progress = (accumulatedIncome / planNumber) * 100
  return progress.toFixed(2) + '%'
}

// 监听数据变化，自动计算累计收入和进度
watch(incomeData, () => {
  // 更新累计收入
  updateAccumulatedIncome()

  // 更新设备进度
  incomeData.value.equipment.forEach(item => {
    item.progress = calculateProgress(item.yearlyPlan, item.accumulatedIncome)
  })

  // 更新元件进度
  incomeData.value.components.forEach(item => {
    item.progress = calculateProgress(item.yearlyPlan, item.accumulatedIncome)
  })

  // 更新工程进度
  incomeData.value.engineering.forEach(item => {
    item.progress = calculateProgress(item.yearlyPlan, item.accumulatedIncome)
  })
}, { deep: true })

// 计算当月收入总额
const currentMonthTotal = computed(() => {
    let total = 0;

    // 计算所有项的当月收入总和
    const allItems = [
        ...incomeData.value.equipment,
        ...incomeData.value.components,
        ...incomeData.value.engineering
    ]

    allItems.forEach(item => {
        total += item.currentMonthIncome || 0;
    });

    return total;
});

// 计算累计收入总额
const accumulatedTotal = computed(() => {
    let total = 0;

    // 计算所有项的累计收入总和
    const allItems = [
        ...incomeData.value.equipment,
        ...incomeData.value.components,
        ...incomeData.value.engineering
    ]

    allItems.forEach(item => {
        total += item.accumulatedIncome || 0;
    });

    return total;
});

// 计算年度计划总额
const yearlyPlanTotal = computed(() => {
    let total = 0;
    let hasValidPlan = false;
    
    const allItems = [
        ...incomeData.value.equipment,
        ...incomeData.value.components,
        ...incomeData.value.engineering
    ]
    
    allItems.forEach(item => {
        if (item.yearlyPlan !== '缺少数据' && item.yearlyPlan) {
            const planNumber = typeof item.yearlyPlan === 'string' ? 
                parseFloat(item.yearlyPlan.replace(/,/g, '')) || 0 : 
                item.yearlyPlan
            total += planNumber
            hasValidPlan = true
        }
    });
    
    return hasValidPlan ? total.toFixed(2) : '缺少数据';
});

// 计算总体进度
const totalProgress = computed(() => {
    if (yearlyPlanTotal.value === '缺少数据') return '/'
    const planTotal = parseFloat(yearlyPlanTotal.value.toString().replace(/,/g, '')) || 0
    if (planTotal === 0) return '/'
    const progress = (accumulatedTotal.value / planTotal) * 100
    return progress.toFixed(2) + '%'
});

// 加载数据
const loadData = async (targetPeriod: string) => {
    console.log('开始加载主营业务收入分解数据:', targetPeriod)
    try {
        // 先加载专用表数据
        const response = await fetch(`http://47.111.95.19:3000/main-business-income/${targetPeriod}`)
        let businessData = null
        if (response.ok) {
            const result = await response.json()
            if (result.success && result.data) {
                businessData = result.data
                console.log('专用表数据:', businessData)
            }
        }
        
        // 再加载form_submissions表数据
        const formResponse = await fetch(`http://47.111.95.19:3000/forms/submission/${MODULE_IDS.MAIN_BUSINESS_INCOME}/${targetPeriod}`)
        let formData = null
        if (formResponse.ok) {
            const formResult = await formResponse.json()
            formData = formResult.data?.formData
            console.log('系统表数据:', formData)
        }
        
        // 合并数据：专用表优先，系统表补充
        if (businessData) {
            // 直接使用API返回的数据，因为已经包含预算信息
            incomeData.value = businessData
            console.log('使用API数据:', incomeData.value)
        } else if (formData) {
            // 如果API没有数据，使用form数据
            incomeData.value = mergeData(getInitialData(), formData)
            console.log('使用表单数据:', incomeData.value)
        } else {
            console.log('该期间暂无数据，保持年度计划但清空当月收入')
            // 保持现有的年度计划值，但将当月收入重置为0
            incomeData.value.equipment.forEach(item => {
                item.currentMonthIncome = 0
                item.progress = '/'
            })
            incomeData.value.components.forEach(item => {
                item.currentMonthIncome = 0
                item.progress = '/'
            })
            incomeData.value.engineering.forEach(item => {
                item.currentMonthIncome = 0
                item.progress = '/'
            })
            console.log('保持年度计划数据:', incomeData.value)
        }

        // 加载所有月份数据并更新累计收入
        await loadAllMonthsData(targetPeriod)
        updateAccumulatedIncome()
    } catch (error) {
        console.error('加载数据失败:', error)
        // 保持现有的年度计划值，但将当月收入重置为0
        incomeData.value.equipment.forEach(item => {
            item.currentMonthIncome = 0
            item.progress = '/'
        })
        incomeData.value.components.forEach(item => {
            item.currentMonthIncome = 0
            item.progress = '/'
        })
        incomeData.value.engineering.forEach(item => {
            item.currentMonthIncome = 0
            item.progress = '/'
        })

        // 即使出错也要尝试加载历史数据
        try {
            await loadAllMonthsData(targetPeriod)
            updateAccumulatedIncome()
        } catch (historyError) {
            console.error('加载历史数据失败:', historyError)
        }
    }
}

// 加载备注数据
const loadRemarksData = async (targetPeriod: string) => {
    try {
        const result = await loadRemarksAndSuggestions(MODULE_IDS.MAIN_BUSINESS_INCOME, targetPeriod)
        remarks.value = result.remarks || ''
        suggestions.value = result.suggestions || ''
    } catch (error) {
        console.error('加载备注和建议失败:', error)
    }
}

// 监听路由参数变化
watch(() => route.query.period, (newPeriod) => {
    if (newPeriod) {
        period.value = newPeriod.toString()
        loadData(newPeriod.toString())
        loadRemarksData(newPeriod.toString())
    }
})

// 监听期间变化
watch(period, (newPeriod) => {
    loadData(newPeriod)
    loadRemarksData(newPeriod)
})

const handleSave = async () => {
    try {
        // 双重保存：专用表 + 系统表
        const saveBusinessData = async () => {
            const response = await fetch('http://47.111.95.19:3000/main-business-income', {
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
                throw new Error('保存专用表失败')
            }
        }
        
        // 先保存专用表数据
        await saveBusinessData()
        
        // 再记录系统表单提交
        await recordFormSubmission(
            MODULE_IDS.MAIN_BUSINESS_INCOME,
            period.value,
            incomeData.value,
            remarks.value,
            suggestions.value
        )

        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败')
    }
}

const handleReset = () => {
    incomeData.value = getInitialData()
    remarks.value = ''
    suggestions.value = ''
}

onMounted(() => {
    if (route.query.period) {
        loadData(route.query.period.toString())
        loadRemarksData(route.query.period.toString())
    } else {
        loadData(period.value)
        loadRemarksData(period.value)
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