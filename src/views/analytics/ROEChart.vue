<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <div class="max-w-7xl mx-auto">
      <!-- 页面标题 -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">净资产收益率分析</h1>
        <p class="text-gray-600 mt-2">净资产收益率 (ROE) 质量情况分析</p>
      </div>

      <!-- 年份选择器 -->
      <div class="bg-white p-6 rounded-lg shadow-sm mb-8">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">数据年份选择</h3>
          <div class="flex items-center space-x-3">
            <span class="text-sm text-gray-600">选择年份:</span>
            <select v-model="selectedYear" @change="fetchData" 
                    class="px-3 py-1.5 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white">
              <option v-for="year in availableYears" :key="year" :value="year">{{ year }}年</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 表一：ROE指标进度条 -->
      
      <!-- 表二：月度趋势图表 -->
      <div class="bg-white rounded-lg shadow-sm p-6 mb-8">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-semibold text-gray-900">{{ selectedYear }}年ROE月度趋势变化</h3>
          <div class="flex items-center space-x-4">
            <div class="flex items-center">
              <div class="w-4 h-4 bg-blue-500 rounded mr-2"></div>
              <span class="text-sm text-gray-600">月度ROE变化</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 bg-red-500 rounded mr-2"></div>
              <span class="text-sm text-gray-600">目标线 (20%)</span>
            </div>
          </div>
        </div>
        <div class="h-[500px]" ref="chartRef"></div>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'

// 响应式数据
const selectedYear = ref(new Date().getFullYear().toString())
const availableYears = ref<string[]>([])
const loading = ref(true)

// 图表引用
const chartRef = ref<HTMLElement | null>(null)

// 图表实例
const chartInstance = ref<echarts.ECharts | null>(null)

// 数据
const months = ref<string[]>([])
const monthlyData = ref<any>({})
const summary = ref<any>({
  currentROE: 0,
  completion_rate: 0,
  targetROE: 20
})

// 工具函数
const formatNumber = (num: number) => {
  return num.toLocaleString('zh-CN', { maximumFractionDigits: 2 })
}

const getCompletionRateColor = (rate: number) => {
  if (rate >= 90) return 'text-green-600'
  if (rate >= 70) return 'text-blue-600'
  if (rate >= 50) return 'text-yellow-600'
  return 'text-red-600'
}

// 初始化年份选项
const initAvailableYears = () => {
  const currentYear = new Date().getFullYear()
  const years: string[] = []
  for (let i = 0; i < 5; i++) {
    years.push((currentYear - i).toString())
  }
  availableYears.value = years
}

// 获取数据
const fetchData = async () => {
  try {
    loading.value = true
    await fetchROEData()
    updateTrendChart()
  } catch (error) {
    console.error('获取数据失败:', error)
  } finally {
    loading.value = false
  }
}

// 重置数据为默认值
const resetDataToDefault = () => {
  months.value = []
  monthlyData.value = {
    roe: []
  }
  summary.value = {
    currentROE: 0,
    completion_rate: 0,
    targetROE: 20
  }
}

// 获取ROE数据
const fetchROEData = async () => {
  try {
    console.log('Fetching ROE data for year:', selectedYear.value);
    const response = await fetch(`http://47.111.95.19:3000/analytics/roe/${selectedYear.value}`);
    
    if (response.ok) {
      const result = await response.json();
      console.log('ROE data response:', result);
      
      if (result.success && result.data) {
        months.value = result.data.months || [];
        monthlyData.value = result.data.monthlyData || { roe: [] };
        
        // 计算汇总数据
        const latestROE = result.data.monthlyData?.roe && result.data.monthlyData.roe.length > 0 ? 
          result.data.monthlyData.roe[result.data.monthlyData.roe.length - 1] : 0;
        
        summary.value = {
          currentROE: latestROE,
          completion_rate: latestROE / 20 * 100,
          targetROE: 20
        };
      } else {
        // 没有数据时重置为默认值
        resetDataToDefault()
      }
    } else {
      // 请求失败时重置为默认值
      resetDataToDefault()
    }
  } catch (error) {
    console.error('获取ROE数据失败:', error);
    // 出错时重置为默认值
    resetDataToDefault()
  }
}

// 初始化图表
const initCharts = () => {
  if (chartRef.value) {
    chartInstance.value = echarts.init(chartRef.value)
  }
}

// 更新趋势图
const updateTrendChart = () => {
  if (!chartInstance.value) return

  try {
    // 准备数据 - 只显示真实数据
    const monthsData = months.value || [];
    const roeData = (monthlyData.value && monthlyData.value.roe) ? monthlyData.value.roe : [];
    
    // 检查是否有数据
    const hasData = monthsData.length > 0 && roeData.length > 0
    
    // 目标线数据
    const targetData = hasData ? monthsData.map(() => 20) : [];
    
    console.log('Chart data:', { monthsData, roeData, targetData, hasData });
  
    // 基本配置
    const option = {
      title: {
        text: `${selectedYear.value}年净资产收益率趋势分析`,
        textStyle: {
          fontSize: 18,
          fontWeight: 'bold',
          color: '#374151'
        },
        left: 'center',
        top: 10
      },
      tooltip: {
        trigger: 'axis',
        formatter: function(params: any[]) {
          if (!hasData) return '暂无数据'
          let result = `${params[0].name}<br/>`
          params.forEach(param => {
            result += `${param.seriesName}: ${formatNumber(param.value)}%<br/>`
          })
          return result
        }
      },
      legend: {
        top: 50,
        type: 'scroll'
      },
      grid: {
        left: '8%',
        right: '5%',
        bottom: '15%',
        top: '25%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: hasData ? monthsData : [],
        axisLabel: {
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        name: '百分比(%)',
        nameTextStyle: {
          fontSize: 12
        },
        axisLabel: {
          formatter: function(value: number) {
            return formatNumber(value) + '%'
          },
          fontSize: 12
        }
      },
      series: hasData ? [
        {
          name: '净资产收益率',
          type: 'line',
          data: roeData,
          smooth: true,
          lineStyle: {
            color: '#3B82F6',
            width: 3
          },
          itemStyle: {
            color: '#3B82F6'
          },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: '#3B82F640' },
              { offset: 1, color: '#3B82F610' }
            ])
          }
        },
        {
          name: '目标线',
          type: 'line',
          data: targetData,
          lineStyle: {
            color: '#EF4444',
            width: 2,
            type: 'dashed'
          },
          itemStyle: {
            color: '#EF4444'
          },
          symbol: 'none'
        }
      ] : [],
      graphic: hasData ? [] : [{
        type: 'text',
        left: 'center',
        top: 'middle',
        style: {
          text: '暂无数据',
          fontSize: 16,
          fontWeight: 'bold',
          fill: '#999'
        }
      }]
    };
    
    chartInstance.value.setOption(option, true);
  } catch (error) {
    console.error('更新趋势图表失败:', error);
  }
}

// 处理窗口大小变化
const handleResize = () => {
  chartInstance.value?.resize()
}

onMounted(async () => {
  initAvailableYears()
  initCharts()
  await fetchData()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  chartInstance.value?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
/* 组件样式 */
</style>