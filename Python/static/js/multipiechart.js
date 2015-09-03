function createMultiplePieChart(dataset) {
  dataset = dataset.sort(function(a, b) {
    return parseFloat(a.geneBodymapTotal) - parseFloat(b.geneBodymapTotal);
  });
  var tooltip = d3.select("body")
    .append("div")
    .style("position", "absolute")
    .style("z-index", "10")
    .style("background-color", "white")
    .style("visibility", "hidden");
  var width = 800,
      height = 800,
      cwidth = 50,
      inner_radius = 35;

  var color = d3.scale.ordinal()
      .range(["#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#d9d9d9", "#bc80bd", "#ccebc5", "#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#FFFFFF"]);

  var pie = d3.layout.pie()
      .sort(null)
      .startAngle(0 * (Math.PI / 180))
      .endAngle(270 * (Math.PI / 180));

  var arc = d3.svg.arc();
  d3.select("svg").remove();
  var svg = d3.select("#chartpie").append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("stroke-width", "2.5")
      .attr("stroke", "white")
      .append("g")
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  var gs = svg.selectAll("g")
      .data(d3.values(dataset)).enter().append("g");
  gs.selectAll("path").data(function(d) {
          return pie(d.bodymapAbsolute.data);
      })
      .enter().append("path")
      .attr("fill", function(d, i) {
          return color(i);
      })
      .attr("d", function(d, i, j) {
          return arc.innerRadius(cwidth * j + inner_radius).outerRadius(cwidth * (j + 1) + inner_radius)(d)
      }).on("mouseover", function(){
        return tooltip.style("visibility", "visible");
      }).on("mousemove", function(d, i, j) {
          tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px");
          tooltip.html(dataset[j].gene + " " + dataset[j].bodymapAbsolute.category[i+1] + " " + d.value);
      }).on("mouseout", function(){
        return tooltip.style("visibility", "hidden");
      }).on("click", function(d, j) {
          alert("Onclick Maybe?:");
      });
  // Add a text label.

  var texts = svg.selectAll("text")
      .data(d3.values(dataset))
      .enter();
  texts.append("text")
      .attr("dy", function(d, i) {
          return "-" + ((inner_radius + 35) + cwidth * i)
      })
      .attr("dx", "-10")
      .attr("stroke", "black")
      .attr("stroke-width", "0")
      .style("text-anchor", "end")
      .attr("class", "inside")
      .text(function(d, i) {
          return d.gene //d.gene
      })
  texts.append("text")
      .attr("dy", function(d, i) {
          return "-" + ((inner_radius + 20) + cwidth * i)
      })
      .attr("dx", "-10")
      .attr("stroke", "black")
      .attr("stroke-width", "0")
      .style("text-anchor", "end")
      .attr("class", "inside")
      .text(function(d, i) {
          return d.geneID //d.geneID
      })
  texts.append("text")
      .attr("dy", function(d, i) {
          return "-" + ((inner_radius + 05) + cwidth * i)
      })
      .attr("dx", "-10")
      .attr("stroke", "black")
      .attr("stroke-width", "0")
      .style("text-anchor", "end")
      .attr("class", "inside")
      .text(function(d, i) {
          return " \u03A3: " + d.geneBodymapTotal //d.geneID
      })
  svg.append("text")
      .attr("stroke", "black")
      .attr("stroke-width", "0")
      .style("text-anchor", "middle")
      .attr("class", "inside")
      .text(function(d) {
          return 'x̄: 15';
      });
}
function createCellTypesChart(dataset) {
  var columndata = [];
  dataset.forEach(function(x) {
    columndata.push(x['celltype']['data']);
  });
  var genenames = [];
  dataset.forEach(function(x) {
    genenames.push(x['gene']);
  });
  var catdata = ["subcerebral_projection_neurons:1", "endothelial:1", "callosal_projection_neurons:2", "newly_formed_oligodendrocyte:1", "endothelial:2", "newly_formed_oligodendrocyte:2", "myelinating_oligodendrocyte:1", "myelinating_oligodendrocyte:2", "oligodendrocyte_precursor:2", "oligodendrocyte_precursor:1", "Colgalt2_pyramidal_cortical_neurons:1", "Colgalt2_pyramidal_cortical_neurons:2", "Colgalt2_pyramidal_cortical_neurons:3", "astrocyte:1", "S100a10_pyramidal_cortical_neurons:2", "S100a10_pyramidal_cortical_neurons:1", "astrocyte:2", "corticothalamic_projection_neurons:1", "ChAT_cholinergic_striatal_neurons:1", "ChAT_cholinergic_striatal_neurons:3", "ChAT_cholinergic_striatal_neurons:2", "S100a10_pyramidal_cortical_neurons:3", "neuron:2", "neuron:1", "D1_striatal_neurons:1", "D1_striatal_neurons:2", "D1_striatal_neurons:3", "microglia:2", "microglia:1"];
    var chart = c3.generate({
  bindto: '#chartscatter',
    point: {
      r: 5,
      opacity:0
  },
  data: {
      columns: columndata
  },
  axis: {
      x: {
          type: 'category',
          categories: catdata,
          tick: {
                rotate: 75,
                multiline: false
            },
          height: 200
      }
  }
  });
  setTimeout(function () {
  chart.transform('scatter');
  }, 1);
}

function createTable(dataset){
  dataset.forEach(function(x) {
    $('#table tbody').append('<tr><td>'+x['gene']+'</td><td>'+x['chromosome']+'</td><td>'+x['source']+'</td></tr>');
  });
}