var dataset = [
  {gene:"LPAR",data : [10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,14]},
  {gene:"CYC1",data : [10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,0]},
  {gene:"LPAR2",data : [10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,0]},
  {gene:"CYC3",data : [10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,0]},
  {gene:"LPAR5",data : [10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,0]}
];
var genes = ["thyroid","testis","ovary","leukocyte","skeletal","muscle","prostate","lymph","node","lung","adipose","adrenal","brain","breast","colon","kidney","heart","liver", "difference"
];

var tooltip = d3.select(".tooltip");

var width = 600,
    height = 400,
    cwidth = 30;

var color = d3.scale.ordinal()
  .range(["#8dd3c7","#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9","#bc80bd","#ccebc5","#8dd3c7","#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#FFFFFF"]);

var pie = d3.layout.pie()
    .sort(null)
    .startAngle(0 * (Math.PI / 180))
    .endAngle(280 * (Math.PI / 180));

var arc = d3.svg.arc();

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("stroke-width", "2.5")
    .attr("stroke", "white")
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
var inner_radius = 30;

var gs = svg.selectAll("g")
.data(d3.values(dataset)).enter().append("g");
gs.selectAll("path").data(function(d) {
        return pie(d.data);
    })
    .enter().append("path")
    .attr("fill", function(d, i) {
        return color(i);
    })
    .attr("d", function(d, i, j) {
        return arc.innerRadius(cwidth * j + inner_radius).outerRadius(cwidth * (j + 1) + inner_radius)(d)
    }).on("mousemove", function(d, i, j) {
            tooltip.style("left", d3.event.pageX + 10 + "px");
            tooltip.style("top", d3.event.pageY - 25 + "px");
            tooltip.style("display", "inline-block");
            tooltip.select("span").text(dataset[j].gene + " " + genes[i] + " " + d.value);
        }).on("mouseout", function() {
            tooltip.style("display", "none");
        }).on("click", function(d, j) {
            alert("Onclick Maybe?:" + d.data.name);
        });
// Add a text label.
      
var texts = svg.selectAll("text")
                .data(d3.values(dataset))
                .enter();
texts.append("text")
.attr("dy",function(d,i){
                    return "-" + ((inner_radius + 10) + cwidth*i)
                })
      .attr("dx", "-10")
      .attr("stroke","black")
      .attr("stroke-width","0")
      .style("text-anchor", "end")
      .attr("class", "inside")
      .text(function(d,i){
                    return d.gene
                })
svg.append("text")
      .attr("stroke","black")
      .attr("stroke-width","0")
      .style("text-anchor", "middle")
      .attr("class", "inside")
      .text(function(d) { return 'x̄: 15'; });