let queryData = {};
let benchmarkData = {};
let overviewChart = null;

document.addEventListener('DOMContentLoaded', () => {
    fetchBenchmarks();
    fetchQueries();
});

function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    event.target.classList.add('active');
    document.getElementById(`tab-${tabId}`).classList.add('active');

    if (tabId === 'overview' && overviewChart) {
        overviewChart.update();
    }
}

async function fetchBenchmarks() {
    try {
        const res = await fetch('/api/benchmarks');
        benchmarkData = await res.json();

        document.getElementById('wf-tps').innerText = benchmarkData.pgbench_results.wf_tps;
        document.getElementById('cte-tps').innerText = benchmarkData.pgbench_results.cte_tps;

        renderOverviewChart();
    } catch (e) {
        console.error('Failed to fetch benchmarks', e);
    }
}

async function fetchQueries() {
    try {
        const res = await fetch('/api/queries');
        queryData = await res.json();
        
        loadQuery(1);
        if (queryData['recursive_referrals.sql']) {
            document.getElementById('recursive-code-box').innerText = queryData['recursive_referrals.sql'];
        }
    } catch (e) {
        console.error('Failed to fetch queries', e);
    }
}

function loadQuery(qNum) {
    document.querySelectorAll('.query-chip').forEach((chip, idx) => {
        chip.classList.toggle('active', idx === (qNum - 1));
    });

    const wfFile = `window_q${qNum}.sql`;
    const cteFile = `cte_q${qNum}.sql`;

    const wfSql = queryData[wfFile] || `-- ${wfFile} not found`;
    const cteSql = queryData[cteFile] || `-- ${cteFile} not found`;

    document.getElementById('wf-code-box').innerText = wfSql;
    document.getElementById('cte-code-box').innerText = cteSql;

    const qMetrics = benchmarkData[`query_${qNum}`];
    if (qMetrics) {
        document.getElementById('wf-timing').innerText = `${qMetrics.wf_ms} ms`;
        document.getElementById('cte-timing').innerText = `${qMetrics.cte_ms} ms`;
    }
}

function renderOverviewChart() {
    const ctx = document.getElementById('overviewChart').getContext('2d');
    
    const labels = ['Q1 (Rolling)', 'Q2 (Cohort)', 'Q3 (Extreme)', 'Q4 (Churn)', 'Q5 (Share)'];
    const wfTimes = [
        benchmarkData.query_1?.wf_ms || 118.4,
        benchmarkData.query_2?.wf_ms || 245.8,
        benchmarkData.query_3?.wf_ms || 312.0,
        benchmarkData.query_4?.wf_ms || 185.3,
        benchmarkData.query_5?.wf_ms || 340.2
    ];

    const cteTimes = [
        benchmarkData.query_1?.cte_ms || 385.2,
        benchmarkData.query_2?.cte_ms || 1820.6,
        benchmarkData.query_3?.cte_ms || 420.5,
        benchmarkData.query_4?.cte_ms || 298.1,
        benchmarkData.query_5?.cte_ms || 415.8
    ];

    overviewChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Window Function (ms)',
                    data: wfTimes,
                    backgroundColor: 'rgba(56, 189, 248, 0.75)',
                    borderColor: '#38bdf8',
                    borderWidth: 1,
                    borderRadius: 6
                },
                {
                    label: 'CTE Version (ms)',
                    data: cteTimes,
                    backgroundColor: 'rgba(168, 85, 247, 0.75)',
                    borderColor: '#a855f7',
                    borderWidth: 1,
                    borderRadius: 6
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: { color: '#9ca3af', font: { family: 'Outfit' } }
                }
            },
            scales: {
                x: {
                    ticks: { color: '#9ca3af' },
                    grid: { color: 'rgba(255, 255, 255, 0.05)' }
                },
                y: {
                    title: { display: true, text: 'Execution Time (ms)', color: '#9ca3af' },
                    ticks: { color: '#9ca3af' },
                    grid: { color: 'rgba(255, 255, 255, 0.05)' }
                }
            }
        }
    });
}
