<template>
    <div class="max-w-[1500px] mx-auto bg-white rounded-lg shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">净利润结构与质量</h1>
            <div class="text-gray-500">(按年度计划口径分解)</div>
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
                        <th class="border border-gray-300 px-4 py-2">当期</th>
                        <th class="border border-gray-300 px-4 py-2">累计</th>
                        <th class="border border-gray-300 px-4 py-2">执行进度</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- 主营业务 -->
                    <tr>
                        <td class="border border-gray-300 px-4 py-2 text-center">1</td>
                        <td class="border border-gray-300 px-4 py-2">主营业务</td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.mainBusiness.plan" type="text" class="w-full px-2 py-1 border rounded bg-gray-100" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.mainBusiness.current" type="text" class="w-full px-2 py-1 border rounded" @input="calculateProgress('mainBusiness')" />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.mainBusiness.cumulative" type="text" class="w-full px-2 py-1 border rounded bg-gray-100" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.mainBusiness.progress" type="text" class="w-full px-2 py-1 border rounded" />
                        </td>
                    </tr>
                    
                    <!-- 非主营业务 -->
                    <tr>
                        <td class="border border-gray-300 px-4 py-2 text-center">2</td>
                        <td class="border border-gray-300 px-4 py-2">非主营业务</td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.nonMainBusiness.plan" type="text" class="w-full px-2 py-1 border rounded bg-gray-100" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.nonMainBusiness.current" type="text" class="w-full px-2 py-1 border rounded" @input="calculateProgress('nonMainBusiness')" />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.nonMainBusiness.cumulative" type="text" class="w-full px-2 py-1 border rounded bg-gray-100" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.nonMainBusiness.progress" type="text" class="w-full px-2 py-1 border rounded" />
                        </td>
                    </tr>
                    
                    <!-- 合计行 -->
                    <tr class="bg-gray-50 font-bold">
                        <td class="border border-gray-300 px-4 py-2 text-center" colspan="2">合计</td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.total.plan" type="text" class="w-full px-2 py-1 border rounded font-bold" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.total.current" type="text" class="w-full px-2 py-1 border rounded font-bold" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.total.cumulative" type="text" class="w-full px-2 py-1 border rounded font-bold" readonly />
                        </td>
                        <td class="border border-gray-300 px-4 py-2">
                            <input v-model="data.total.progress" type="text" class="w-full px-2 py-1 border rounded font-bold" readonly />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="mt-4 flex justify-end space-x-4">
            <button @click="handleSave" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                保存
            </button>
            <button @click="handleReset" class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
                重置
            </button>
        </div>
        
        <!-- 文件上传和备注组件 -->
        <FormAttachmentAndRemarks 
            :module-id="MODULE_IDS.NET_PROFIT_STRUCTURE"
            :period="period"
            v-model:remarks="remarks"
            v-model:suggestions="suggestions"
        />
    </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, watch, reactive, computed } from 'vue'
import { useRoute } from 'vue-router'
import FormAttachmentAndRemarks from '@/components/FormAttachmentAndRemarks.vue'
import { recordFormSubmission, loadRemarksAndSuggestions, MODULE_IDS } from '@/utils/formSubmissionHelper'

const route = useRoute()
const period = ref(route.query.period?.toString() || new Date().toISOString().slice(0, 7))
const remarks = ref('')
const suggestions = ref('')

interface ProfitItem {
    plan: string;
    current: string;
    cumulative: string;
    progress: string;
}

// 注意：预算数据由后端中间件从数据库动态获取，不在前端写死

// 初始化数据模板（当没有数据时使用）
const getInitialData = () => ({
    mainBusiness: { plan: '0', current: '0', cumulative: '0', progress: '0.00%' },
    nonMainBusiness: { plan: '0', current: '0', cumulative: '0', progress: '0.00%' },
    total: { plan: '0', current: '0', cumulative: '0', progress: '0.00%' }
})

// 响应式数据
const data = reactive<{
    mainBusiness: ProfitItem;
    nonMainBusiness: ProfitItem;
    total: ProfitItem;
}>(getInitialData())

// 计算执行进度
const calculateProgress = (type: 'mainBusiness' | 'nonMainBusiness') => {
    // 移除逗号并转换为数字
    const plan = parseFloat(data[type].plan.replace(/,/g, ''))
    const cumulative = parseFloat(data[type].cumulative.replace(/,/g, ''))
    
    if (!isNaN(plan) && !isNaN(cumulative) && plan !== 0) {
        const progress = (cumulative / plan * 100).toFixed(2)
        data[type].progress = `${progress}%`
    } else {
        data[type].progress = '0.00%'
    }
    
    calculateTotal()
}

// 计算合计
const calculateTotal = () => {
    // 移除逗号并转换为数字
    const mainPlan = parseFloat(data.mainBusiness.plan.replace(/,/g, '')) || 0
    const nonMainPlan = parseFloat(data.nonMainBusiness.plan.replace(/,/g, '')) || 0
    const mainCurrent = parseFloat(data.mainBusiness.current.replace(/,/g, '')) || 0
    const nonMainCurrent = parseFloat(data.nonMainBusiness.current.replace(/,/g, '')) || 0
    const mainCumulative = parseFloat(data.mainBusiness.cumulative.replace(/,/g, '')) || 0
    const nonMainCumulative = parseFloat(data.nonMainBusiness.cumulative.replace(/,/g, '')) || 0
    
    const totalPlan = mainPlan + nonMainPlan
    const totalCurrent = mainCurrent + nonMainCurrent
    const totalCumulative = mainCumulative + nonMainCumulative
    
    // 格式化为带千分位的数字
    data.total.plan = totalPlan.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    data.total.current = totalCurrent.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    data.total.cumulative = totalCumulative.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    
    if (totalPlan !== 0) {
        const totalProgress = (totalCumulative / totalPlan * 100).toFixed(2)
        data.total.progress = `${totalProgress}%`
    } else {
        data.total.progress = '0.00%'
    }
}

// 监听路由参数变化
watch(() => route.query.period, (newPeriod) => {
    if (newPeriod) {
        period.value = newPeriod.toString()
        loadData(newPeriod.toString())
    }
})

// 监听period值变化，当用户手动修改月份下拉框时重新加载数据
watch(period, (newPeriod, oldPeriod) => {
    if (newPeriod && newPeriod !== oldPeriod) {
        console.log(`期间发生变化: ${oldPeriod} -> ${newPeriod}`)
        loadData(newPeriod)
        loadRemarksData()
    }
})

// 监听当期值变化，自动重新计算累计值
watch(() => [data.mainBusiness.current, data.nonMainBusiness.current], async () => {
    await calculateCumulativeValues()
}, { deep: true })

// 计算累计值函数
const calculateCumulativeValues = async () => {
    try {
        const [year] = period.value.split('-')
        let mainBusinessCumulative = 0
        let nonMainBusinessCumulative = 0
        
        // 获取从年初到当前期间的所有数据
        for (let month = 1; month <= parseInt(period.value.split('-')[1]); month++) {
            const monthPeriod = `${year}-${month.toString().padStart(2, '0')}`
            
            try {
                const response = await fetch(`http://47.111.95.19:3000/net-profit-structure/${monthPeriod}`)
                if (response.ok) {
                    const result = await response.json()
                    if (result.success && result.data) {
                        const currentValue = parseFloat(result.data.mainBusiness?.current || result.data.mainBusiness?.actual || 0)
                        const nonMainCurrentValue = parseFloat(result.data.nonMainBusiness?.current || result.data.nonMainBusiness?.actual || 0)
                        
                        mainBusinessCumulative += currentValue
                        nonMainBusinessCumulative += nonMainCurrentValue
                    }
                }
            } catch (error) {
                console.log(`跳过期间 ${monthPeriod} 的数据计算:`, error)
            }
        }
        
        // 更新累计值
        data.mainBusiness.cumulative = mainBusinessCumulative.toFixed(2)
        data.nonMainBusiness.cumulative = nonMainBusinessCumulative.toFixed(2)
        data.total.cumulative = (mainBusinessCumulative + nonMainBusinessCumulative).toFixed(2)
        
        // 重新计算进度
        calculateProgress('mainBusiness')
        calculateProgress('nonMainBusiness')
        
    } catch (error) {
        console.error('计算累计值失败:', error)
    }
}

// 合并数据：将从数据库加载的数据与初始模板合并
const mergeData = (templateData: any, loadedData: any): any => {
    if (!loadedData) return templateData
    
    return {
        mainBusiness: {
            plan: loadedData.mainBusiness?.plan || templateData.mainBusiness.plan,
            current: loadedData.mainBusiness?.current || loadedData.mainBusiness?.actual || templateData.mainBusiness.current,
            cumulative: loadedData.mainBusiness?.cumulative || templateData.mainBusiness.cumulative,
            progress: loadedData.mainBusiness?.progress || templateData.mainBusiness.progress
        },
        nonMainBusiness: {
            plan: loadedData.nonMainBusiness?.plan || templateData.nonMainBusiness.plan,
            current: loadedData.nonMainBusiness?.current || loadedData.nonMainBusiness?.actual || templateData.nonMainBusiness.current,
            cumulative: loadedData.nonMainBusiness?.cumulative || templateData.nonMainBusiness.cumulative,
            progress: loadedData.nonMainBusiness?.progress || templateData.nonMainBusiness.progress
        },
        total: {
            plan: loadedData.total?.plan || templateData.total.plan,
            current: loadedData.total?.current || loadedData.total?.actual || templateData.total.current,
            cumulative: loadedData.total?.cumulative || templateData.total.cumulative,
            progress: loadedData.total?.progress || templateData.total.progress
        }
    }
}

// 加载数据
const loadData = async (targetPeriod: string) => {
    try {
        console.log(`正在加载净利润结构数据，期间: ${targetPeriod}`)
        
        const response = await fetch(`http://47.111.95.19:3000/net-profit-structure/${targetPeriod}`)
        let loadedData: any = null
        
        if (response.ok) {
            const result = await response.json()
            console.log('API返回数据:', result)
            
            if (result.success && result.data) {
                loadedData = result.data
                console.log('成功获取数据，开始合并...')
                
                // 直接使用后端返回的数据（已包含预算数据）
                data.mainBusiness = {
                    plan: loadedData.mainBusiness?.plan || '0',
                    current: loadedData.mainBusiness?.current || loadedData.mainBusiness?.actual || '0',
                    cumulative: loadedData.mainBusiness?.cumulative || '0',
                    progress: loadedData.mainBusiness?.progress || '0.00%'
                }
                data.nonMainBusiness = {
                    plan: loadedData.nonMainBusiness?.plan || '0',
                    current: loadedData.nonMainBusiness?.current || loadedData.nonMainBusiness?.actual || '0',
                    cumulative: loadedData.nonMainBusiness?.cumulative || '0',
                    progress: loadedData.nonMainBusiness?.progress || '0.00%'
                }
                data.total = {
                    plan: loadedData.total?.plan || '0',
                    current: loadedData.total?.current || loadedData.total?.actual || '0',
                    cumulative: loadedData.total?.cumulative || '0',
                    progress: loadedData.total?.progress || '0.00%'
                }
                
                calculateTotal()
                console.log('合并后的数据:', data)
            }
        } else {
            console.log('加载数据失败')
            throw new Error('加载数据失败')
        }
        
    } catch (error) {
        console.error('加载数据失败:', error)
        // 出错时也要确保预算数据显示
        const initialData = getInitialData()
        data.mainBusiness = { ...initialData.mainBusiness }
        data.nonMainBusiness = { ...initialData.nonMainBusiness }
        data.total = { ...initialData.total }
    }
}

// 保存数据
const handleSave = async () => {
    try {
        const formData = {
            mainBusiness: data.mainBusiness,
            nonMainBusiness: data.nonMainBusiness,
            total: data.total
        }
        
        const saveData = {
            period: period.value,
            data: formData
        }

        console.log('保存数据:', saveData)

        // 1. 保存到 net_profit_structure 表
        const response = await fetch('http://47.111.95.19:3000/net-profit-structure', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(saveData)
        })

        if (!response.ok) {
            const errorText = await response.text()
            throw new Error(`保存失败: ${response.status} - ${errorText}`)
        }

        // 2. 保存到 form_submissions 表
        await recordFormSubmission(MODULE_IDS.NET_PROFIT_STRUCTURE, period.value, formData, remarks.value, suggestions.value)

        alert('保存成功')
    } catch (error) {
        console.error('保存失败:', error)
        alert('保存失败: ' + (error instanceof Error ? error.message : '未知错误'))
    }
}

// 重置数据
const handleReset = () => {
    const initialData = getInitialData()
    data.mainBusiness = { ...initialData.mainBusiness }
    data.nonMainBusiness = { ...initialData.nonMainBusiness }
    data.total = { ...initialData.total }
    console.log('已重置为初始数据')
}

// 加载备注和建议
const loadRemarksData = async () => {
    const { remarks: loadedRemarks, suggestions: loadedSuggestions } = await loadRemarksAndSuggestions(MODULE_IDS.NET_PROFIT_STRUCTURE, period.value)
    remarks.value = loadedRemarks
    suggestions.value = loadedSuggestions
}

onMounted(() => {
    console.log('组件挂载，当前期间:', period.value)
    loadData(period.value)
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