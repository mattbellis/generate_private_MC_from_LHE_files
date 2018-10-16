sed '/process.mixData.input.fileNames/r test.txt' -i madgraph_ttbar_tWb_SMALL-RunIISummer16DR80Premix-00008_1_cfg.py

# To delete lines
sed '/process.mixData.input.fileNames/d' madgraph_ttbar_tWb_SMALL-RunIISummer16DR80Premix-00008_1_cfg.py
