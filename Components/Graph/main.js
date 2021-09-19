function readTextFile(file, callback) {
    var rawFile = new XMLHttpRequest();
    rawFile.overrideMimeType("application/json");
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function () {
        if (rawFile.readyState === 4 && rawFile.status == "200") {
            callback(rawFile.responseText);
        }
    }
    rawFile.send(null);
}

function createBarChart(dataJson) {
    readTextFile('data.json', function (text) {
        dataJson = (JSON.parse(text))
        var colorsMeaning = ['very_good', 'good', 'average', 'worse', 'bad'];
        const TROW = 'tr',
            TDATA = 'td';

        function turnIntoTime(timestamp) {
            var hours = Math.floor(timestamp / 60 / 60);
            var minutes = Math.floor(timestamp / 60) - (hours * 60);
            if ((minutes + '').length < 2) {
                minutes = '0' + minutes;
            }
            var seconds = Math.floor(timestamp % 60);
            if ((seconds + '').length < 2) {
                seconds = '0' + seconds;
            }
            return `${hours}:${minutes}:${seconds}`;
        }

        const YEARS = Object.keys(dataJson);
        let TIME_VALUES = [];
        let MONTH_VALUES = [];
        let dataOfEveryYearsArray = [];
        for (let i = 0; i < YEARS.length; i++) {
            dataOfEveryYearsArray.push(Object.values(dataJson)[i])
        }

        for (let i = 0; i < dataOfEveryYearsArray.length; i++) {
            TIME_VALUES.push(Object.values(dataOfEveryYearsArray[i]));
            TIME_VALUES = TIME_VALUES.flat();
            MONTH_VALUES.push(Object.keys(dataOfEveryYearsArray[i]));
            MONTH_VALUES = MONTH_VALUES.flat();
        }

        var chart = document.createElement('div');
        var barchart = document.createElement('table');
        var titlerow = document.createElement(TROW);
        var titledata = document.createElement(TDATA);
        var barrow = document.createElement(TROW);
        titledata.setAttribute('colspan', 'MONTH_VALUES.length');
        barchart.appendChild(titlerow);
        chart.appendChild(barchart);

        for (let i = 0; i < dataOfEveryYearsArray.length; i++) {
            let dataKeys = Object.keys(dataOfEveryYearsArray[i]);
            let dataValues = Object.values(dataOfEveryYearsArray[i]);
            for (let j = 0; j < dataKeys.length; j++) {
                barrow.setAttribute('class', 'bars');
                var bardata = document.createElement(TDATA);
                var bar = document.createElement('div');
                //bar.setAttribute('class', colors[i]);

                if (dataValues[j] == Math.max(...TIME_VALUES)) {
                    bar.style.height = "90%";
                } else {
                    bar.style.height = ((dataValues[j] * 90) / Math.max(...TIME_VALUES)) + '%';
                }
                bardata.innerText = turnIntoTime(dataValues[j]);

                var hours = Math.floor(dataValues[j] / 60 / 60);
                var minutes = Math.floor(dataValues[j] / 60) - (hours * 60);

                if (minutes <= 30 && hours < 1) {
                    bar.setAttribute('class', colorsMeaning[0]);
                } else if ((hours === 1 && minutes <= 30) || (hours < 1 && minutes >= 30)) {
                    bar.setAttribute('class', colorsMeaning[1]);
                } else if (hours < 3) {
                    bar.setAttribute('class', colorsMeaning[2]);
                } else if (hours < 4) {
                    bar.setAttribute('class', colorsMeaning[3]);
                } else {
                    bar.setAttribute('class', colorsMeaning[4]);
                }

                bardata.appendChild(bar);
                barrow.appendChild(bardata);
                var barmonth = document.createElement('div');
                barmonth.innerText = dataKeys[j] + ` 202${[i]}`;
                bardata.appendChild(barmonth);
            }
        }
        barchart.appendChild(barrow);
        chart.appendChild(barchart);
        document.getElementById('chart').innerHTML = chart.outerHTML;
    })
}

createBarChart();