%TEST Generates the tables and plots used in the 
% manuscript 'Simulating Low Precision Floating-Point
% Arithmetic -- N.J.Higham and S.Pranesh'

clear all; close all;

addpath('MainFunctions/')
addpath('MainScripts/')


LUTime;
euler_exp;
sum_series;

movefile('*.txt','results')
movefile('*.mat','results')